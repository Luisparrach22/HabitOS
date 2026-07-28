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
        
        // 4. Vincular todos los hábitos existentes en la base de datos a este usuario (por seguridad)
        let habitsFetch = FetchDescriptor<Habit>()
        let allHabits = try modelContext.fetch(habitsFetch)
        for habit in allHabits {
            if habit.userId != user.id {
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
}
