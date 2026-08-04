// ──────────────────────────────────────────────
// SupabaseService.swift — Servicio de Sincronización con Supabase
// ──────────────────────────────────────────────

import Foundation
import Supabase

// MARK: - Soporte de Fechas Flexibles para PostgreSQL
// PostgreSQL utiliza timestamps sin zona horaria, lo que a veces confunde al decoder ISO8601 por defecto de Swift.
// Este wrapper analiza de forma robusta cualquier formato de fecha recibido.
struct FlexibleDate: Codable, Hashable {
    let date: Date
    
    init(_ date: Date) {
        self.date = date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // 1. Intentar decodificar como Date estándar
        if let decodedDate = try? container.decode(Date.self) {
            self.date = decodedDate
            return
        }
        
        // 2. Intentar decodificar como String y parsear formatos comunes de PostgreSQL/ISO8601
        let dateString = try container.decode(String.self)
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",
            "yyyy-MM-dd HH:mm:ss.SSS",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let parsedDate = formatter.date(from: dateString) {
                self.date = parsedDate
                return
            }
        }
        
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Formato de fecha de Supabase inválido: \(dateString)"
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(date)
    }
}

// MARK: - DTOs (Data Transfer Objects) para Supabase SQL

struct SupabaseUserDTO: Codable {
    let id: String
    let email: String
    let name: String?
    let passwordHash: String
    let avatarUrl: String?
    let totalXp: Int
    let level: Int
    let isPro: Bool
    let timezone: String
    let createdAt: FlexibleDate
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, avatarUrl, totalXp, level, isPro, timezone, createdAt
        case passwordHash = "passwordHash"
    }
}

struct SupabaseHabitDTO: Codable {
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
    let createdAt: FlexibleDate
    
    enum CodingKeys: String, CodingKey {
        case id, userId, name, trigger, frequency, color, icon, currentStreak, maxStreak, shields, createdAt
        case description = "description"
    }
}

struct SupabaseHabitLogDTO: Codable {
    let id: String
    let habitId: String
    let completedAt: FlexibleDate
    let value: Int
    let notes: String?
}

struct SupabaseShieldUsageDTO: Codable {
    let id: String
    let habitId: String
    let usedAt: FlexibleDate
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
        
        // Nuevos usuarios comienzan sin Pro — el estado se gestiona desde Supabase o StoreKit
        let isPro = false
        
        // Crear perfil en la tabla publica User
        let userDTO = SupabaseUserDTO(
            id: userId,
            email: email,
            name: name,
            passwordHash: "managed_by_supabase_auth",
            avatarUrl: nil,
            totalXp: 0,
            level: 1,
            isPro: isPro,
            timezone: TimeZone.current.identifier,
            createdAt: FlexibleDate(Date())
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
    
    func syncUser(_ userDTO: SupabaseUserDTO) async throws {
        try await supabase
            .from("User")
            .upsert(userDTO)
            .execute()
    }
    
    func fetchUser(id: String) async throws -> SupabaseUserDTO? {
        let response: [SupabaseUserDTO] = try await supabase
            .from("User")
            .select()
            .eq("id", value: id)
            .execute()
            .value
        return response.first
    }
    
    // MARK: - Operaciones de Hábitos
    
    func syncHabit(_ habitDTO: SupabaseHabitDTO) async throws {
        try await supabase
            .from("Habit")
            .upsert(habitDTO)
            .execute()
    }
    
    func fetchHabits(userId: String) async throws -> [SupabaseHabitDTO] {
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
    
    func syncHabitLog(_ logDTO: SupabaseHabitLogDTO) async throws {
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
    
    func syncShieldUsage(_ shieldDTO: SupabaseShieldUsageDTO) async throws {
        try await supabase
            .from("ShieldUsage")
            .upsert(shieldDTO)
            .execute()
    }
}
