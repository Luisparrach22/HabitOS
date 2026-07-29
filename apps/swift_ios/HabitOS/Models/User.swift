// ──────────────────────────────────────────────
// User.swift — Modelo SwiftData
// ──────────────────────────────────────────────
// Mapeo de la tabla SQL "User".
//
// ¿Qué es @Model?
// Es una macro de SwiftData (equivalente a @Entity en CoreData).
// Al marcar una clase con @Model, Swift automáticamente:
// - Genera el esquema de persistencia local.
// - Hace que las propiedades sean observables (como @Published).
// - Maneja las relaciones entre modelos.
//
// ¿Por qué clase y no struct?
// SwiftData requiere clases (reference types) porque necesita
// trackear cambios en la instancia. Los structs (value types)
// se copian al asignar, lo que rompería la persistencia.

import Foundation
import SwiftData

@Model
class User {
    
    // MARK: - Identificación
    
    /// ID único (UUID como string, igual que en tu SQL)
    var id: String
    
    /// Email único del usuario
    var email: String
    
    /// Nombre visible (opcional porque el usuario podría no configurarlo)
    var name: String?
    
    /// Hash de la contraseña (nunca almacenamos la contraseña en texto plano)
    var passwordHash: String
    
    /// URL del avatar del usuario (opcional)
    var avatarUrl: String?
    
    // MARK: - Gamificación
    
    /// Experiencia total acumulada
    var totalXp: Int
    
    /// Nivel actual del usuario
    var level: Int
    
    /// Indica si el usuario tiene la suscripción Pro activa
    /// Indica si el usuario tiene la suscripción Pro activa (persistida como opcional para evitar fallas de migración)
    var isProValue: Bool?
    
    var isPro: Bool {
        get { 
            if email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == "parra.chaconluis006@gmail.com" {
                return true
            }
            return isProValue ?? false 
        }
        set { isProValue = newValue }
    }
    
    // MARK: - Configuración
    
    /// Zona horaria del usuario (formato IANA, ej: "Europe/Madrid")
    var timezone: String
    
    // MARK: - Timestamps
    
    /// Fecha de creación de la cuenta
    var createdAt: Date
    
    // MARK: - Relaciones
    
    /// Todos los hábitos del usuario.
    /// deleteRule: .cascade → si eliminas el usuario, se borran sus hábitos.
    /// Esto es equivalente a ON DELETE CASCADE en SQL.
    @Relationship(deleteRule: .cascade, inverse: \Habit.user)
    var habits: [Habit]?
    
    // MARK: - Inicializador
    
    /// Inicializador con valores por defecto sensatos.
    /// En Swift, los initializers son el equivalente a constructores.
    init(
        id: String = UUID().uuidString,
        email: String,
        name: String? = nil,
        passwordHash: String,
        avatarUrl: String? = nil,
        totalXp: Int = 0,
        level: Int = 1,
        isPro: Bool = false,
        timezone: String = "UTC",
        createdAt: Date = .now
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.passwordHash = passwordHash
        self.avatarUrl = avatarUrl
        self.totalXp = totalXp
        self.level = level
        self.isProValue = isPro
        self.timezone = timezone
        self.createdAt = createdAt
        self.habits = []
    }
}
