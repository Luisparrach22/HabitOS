// ──────────────────────────────────────────────
// AuthService.swift — Servicio de Autenticación Local
// ──────────────────────────────────────────────
// Gestiona el registro, inicio y cierre de sesión de usuarios,
// cifrando contraseñas con SHA256 usando CryptoKit.

import Foundation
import CryptoKit
import SwiftData

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    /// Genera un hash SHA256 hexadecimal a partir de una contraseña en texto plano
    func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Registra un nuevo usuario en la base de datos local y vincula los hábitos semillas del onboarding
    func register(name: String, email: String, password: String, modelContext: ModelContext) throws -> User {
        let cleanEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Validar que no esté vacío
        guard !cleanEmail.isEmpty, !password.isEmpty else {
            throw NSError(domain: "AuthService", code: 400, userInfo: [NSLocalizedDescriptionKey: "El correo y la contraseña son obligatorios."])
        }
        
        // 2. Verificar duplicados
        let fetchDescriptor = FetchDescriptor<User>()
        let allUsers = try modelContext.fetch(fetchDescriptor)
        
        if allUsers.contains(where: { $0.email == cleanEmail }) {
            throw NSError(domain: "AuthService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Ya existe una cuenta registrada con este correo electrónico."])
        }
        
        let passwordHash = hashPassword(password)
        let user: User
        
        // 3. Si existe el usuario semilla temporal del onboarding, lo actualizamos para conservar sus hábitos y progreso
        if let onboardingUser = allUsers.first(where: { $0.email == "usuario@habitos.app" && $0.passwordHash == "local" }) {
            onboardingUser.name = name.isEmpty ? nil : name
            onboardingUser.email = cleanEmail
            onboardingUser.passwordHash = passwordHash
            onboardingUser.createdAt = Date()
            user = onboardingUser
        } else {
            // Si no, creamos un nuevo usuario desde cero
            let newUser = User(
                email: cleanEmail,
                name: name.isEmpty ? nil : name,
                passwordHash: passwordHash,
                timezone: TimeZone.current.identifier
            )
            modelContext.insert(newUser)
            user = newUser
        }
        
        // 4. Vincular hábitos huérfanos del onboarding (no reasignar hábitos de otros usuarios)
        let habitsFetch = FetchDescriptor<Habit>()
        let allHabits = try modelContext.fetch(habitsFetch)
        for habit in allHabits {
            // Solo vincular hábitos sin dueño asignado o del usuario temporal de onboarding
            if habit.user == nil || habit.userId.isEmpty {
                habit.userId = user.id
                habit.user = user
            }
        }
        
        try modelContext.save()
        return user
    }
    
    /// Inicia sesión buscando un usuario con el correo y hash de contraseña correspondientes
    func login(email: String, password: String, modelContext: ModelContext) throws -> User {
        let cleanEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordHash = hashPassword(password)
        
        let fetchDescriptor = FetchDescriptor<User>()
        let allUsers = try modelContext.fetch(fetchDescriptor)
        
        if let matchedUser = allUsers.first(where: { $0.email == cleanEmail && $0.passwordHash == passwordHash }) {
            // Si iniciamos sesión con un usuario diferente, vinculamos los hábitos correspondientes a su ID
            let habitsFetch = FetchDescriptor<Habit>()
            let allHabits = try modelContext.fetch(habitsFetch)
            for habit in allHabits {
                if habit.userId == matchedUser.id {
                    habit.user = matchedUser
                }
            }
            return matchedUser
        } else {
            throw NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "El correo electrónico o la contraseña son incorrectos."])
        }
    }
    
    // MARK: - Supabase Async Integration
    
    /// Registra al usuario en Supabase Auth y sincroniza el perfil y hábitos en SwiftData y Supabase SQL
    func registerWithSupabase(name: String, email: String, password: String, modelContext: ModelContext) async throws -> User {
        let cleanEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Registrar en Supabase Auth
        let supabaseUserId = try await SupabaseService.shared.signUp(email: cleanEmail, password: password, name: name)
        
        // 2. Registrar/Actualizar localmente en SwiftData
        let localUser = try register(name: name, email: cleanEmail, password: password, modelContext: modelContext)
        
        // Sincronizar ID de Supabase si aplica
        localUser.id = supabaseUserId
        try modelContext.save()
        
        // 3. Sincronizar todos los hábitos del usuario con Supabase
        if let habits = localUser.habits {
            for habit in habits {
                let habitDTO = SupabaseHabitDTO(
                    id: habit.id,
                    userId: supabaseUserId,
                    name: habit.name,
                    description: habit.habitDescription,
                    trigger: habit.trigger,
                    frequency: habit.frequency.rawValue,
                    color: habit.color,
                    icon: habit.icon,
                    currentStreak: habit.currentStreak,
                    maxStreak: habit.maxStreak,
                    shields: habit.shields,
                    createdAt: FlexibleDate(habit.createdAt)
                )
                try? await SupabaseService.shared.syncHabit(habitDTO)
            }
        }
        
        return localUser
    }
    
    /// Inicia sesión con Supabase Auth y sincroniza los datos locales
    func loginWithSupabase(email: String, password: String, modelContext: ModelContext) async throws -> User {
        let cleanEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Iniciar sesión en Supabase Auth
        let supabaseUserId = try await SupabaseService.shared.signIn(email: cleanEmail, password: password)
        
        // 2. Intentar buscar o crear localmente
        let passwordHash = hashPassword(password)
        let fetchDescriptor = FetchDescriptor<User>()
        let allUsers = try modelContext.fetch(fetchDescriptor)
        
        let user: User
        if let matchedUser = allUsers.first(where: { $0.email == cleanEmail }) {
            matchedUser.passwordHash = passwordHash
            matchedUser.id = supabaseUserId
            user = matchedUser
        } else {
            let newUser = User(
                id: supabaseUserId,
                email: cleanEmail,
                passwordHash: passwordHash,
                timezone: TimeZone.current.identifier
            )
            modelContext.insert(newUser)
            user = newUser
        }
        
        try modelContext.save()
        
        // 3. Intentar obtener datos actualizados del perfil desde Supabase
        do {
            if let remoteUser = try await SupabaseService.shared.fetchUser(id: supabaseUserId) {
                user.name = remoteUser.name
                user.totalXp = remoteUser.totalXp
                user.level = remoteUser.level
                user.avatarUrl = remoteUser.avatarUrl
                user.isPro = remoteUser.isPro
                try modelContext.save()
            }
        } catch {
            #if DEBUG
            print("❌ Error fetching user profile from Supabase: \(error)")
            #endif
        }
        
        return user
    }
    
    /// Sincroniza el perfil del usuario actual desde Supabase a la base de datos local
    func syncProfile(userId: String, modelContext: ModelContext) async {
        let cleanUserId = userId.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanUserId.isEmpty else { return }
        
        do {
            if let remoteUser = try await SupabaseService.shared.fetchUser(id: cleanUserId) {
                let fetchDescriptor = FetchDescriptor<User>()
                let allUsers = try modelContext.fetch(fetchDescriptor)
                if let user = allUsers.first(where: { $0.id == cleanUserId }) {
                    // Solo guardar si hay cambios para evitar escrituras innecesarias
                    if user.name != remoteUser.name ||
                        user.totalXp != remoteUser.totalXp ||
                        user.level != remoteUser.level ||
                        user.avatarUrl != remoteUser.avatarUrl ||
                        (user.isProValue ?? false) != remoteUser.isPro {
                        
                        user.name = remoteUser.name
                        user.totalXp = remoteUser.totalXp
                        user.level = remoteUser.level
                        user.avatarUrl = remoteUser.avatarUrl
                        user.isPro = remoteUser.isPro
                        try modelContext.save()
                        
                        #if DEBUG
                        print("✅ Perfil sincronizado con Supabase. Pro: \(remoteUser.isPro)")
                        #endif
                    }
                }
            }
        } catch {
            #if DEBUG
            print("❌ Fallo al sincronizar el perfil con Supabase: \(error)")
            #endif
        }
    }
}

