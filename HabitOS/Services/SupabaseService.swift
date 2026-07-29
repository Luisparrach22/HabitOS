// ──────────────────────────────────────────────
// SupabaseService.swift — Servicio de Sincronización con Supabase
// ──────────────────────────────────────────────

import Foundation
import Supabase

// MARK: - DTOs (Data Transfer Objects) para Supabase SQL

struct UserDTO: Codable {
    let id: String
    let email: String
    let name: String?
    let passwordHash: String
    let avatarUrl: String?
    let totalXp: Int
    let level: Int
    let timezone: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, avatarUrl, totalXp, level, timezone, createdAt
        case passwordHash = "passwordHash"
    }
}

struct HabitDTO: Codable {
    let id: String
    let userId: String
    let name: String
    let description: String?
    let trigger: String?
    let frequency: String
    let color: String?
    let icon: String?
    let currentStreak: Int
    let maxStreak: Int
    let shields: Int
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, userId, name, trigger, frequency, color, icon, currentStreak, maxStreak, shields, createdAt
        case description = "description"
    }
}

struct HabitLogDTO: Codable {
    let id: String
    let habitId: String
    let completedAt: Date
    let value: Int
    let notes: String?
}

struct ShieldUsageDTO: Codable {
    let id: String
    let habitId: String
    let usedAt: Date
    let reason: String?
}

// MARK: - Servicio Principal

class SupabaseService {
    static let shared = SupabaseService()
    
    private init() {}
    
    // MARK: - Autenticación
    
    /// Registra un nuevo usuario en Supabase Auth y luego inserta su perfil en la tabla User
    func signUp(email: String, password: String, name: String?) async throws -> String {
        let authResponse = try await supabase.auth.signUp(
            email: email,
            password: password
        )
        
        let userId = authResponse.user.id.uuidString.lowercased()
        
        // Crear perfil en la tabla publica User
        let userDTO = UserDTO(
            id: userId,
            email: email,
            name: name,
            passwordHash: "managed_by_supabase_auth",
            avatarUrl: nil,
            totalXp: 0,
            level: 1,
            timezone: TimeZone.current.identifier,
            createdAt: Date()
        )
        
        try await syncUser(userDTO)
        return userId
    }
    
    /// Inicia sesión en Supabase Auth
    func signIn(email: String, password: String) async throws -> String {
        let authResponse = try await supabase.auth.signIn(
            email: email,
            password: password
        )
        return authResponse.user.id.uuidString.lowercased()
    }
    
    // MARK: - Operaciones de Usuario
    
    func syncUser(_ userDTO: UserDTO) async throws {
        try await supabase
            .from("User")
            .upsert(userDTO)
            .execute()
    }
    
    func fetchUser(id: String) async throws -> UserDTO? {
        let response: [UserDTO] = try await supabase
            .from("User")
            .select()
            .eq("id", value: id)
            .execute()
            .value
        return response.first
    }
    
    // MARK: - Operaciones de Hábitos
    
    func syncHabit(_ habitDTO: HabitDTO) async throws {
        try await supabase
            .from("Habit")
            .upsert(habitDTO)
            .execute()
    }
    
    func fetchHabits(userId: String) async throws -> [HabitDTO] {
        return try await supabase
            .from("Habit")
            .select()
            .eq("userId", value: userId)
            .execute()
            .value
    }
    
    func deleteHabit(id: String) async throws {
        try await supabase
            .from("Habit")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    // MARK: - Operaciones de Logs de Hábitos
    
    func syncHabitLog(_ logDTO: HabitLogDTO) async throws {
        try await supabase
            .from("HabitLog")
            .upsert(logDTO)
            .execute()
    }
    
    func deleteHabitLog(id: String) async throws {
        try await supabase
            .from("HabitLog")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    // MARK: - Operaciones de Escudos
    
    func syncShieldUsage(_ shieldDTO: ShieldUsageDTO) async throws {
        try await supabase
            .from("ShieldUsage")
            .upsert(shieldDTO)
            .execute()
    }
}
