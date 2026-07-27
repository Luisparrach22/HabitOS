// ──────────────────────────────────────────────
// Habit.swift — Modelo SwiftData + Enum Frequency
// ──────────────────────────────────────────────
// Mapeo de la tabla SQL "Habit" y el enum "Frequency".
//
// ¿Qué es un enum en Swift?
// Es idéntico conceptualmente a un enum en TypeScript,
// pero con esteroides: puede tener propiedades, métodos
// y conformar protocolos (interfaces en TS).
//
// ¿Por qué Codable?
// Permite serializar/deserializar automáticamente.
// Cuando sincronices con tu API, el JSON { "frequency": "DAILY" }
// se convertirá a Frequency.daily automáticamente.

import Foundation
import SwiftData

// MARK: - Enum de frecuencia

/// Frecuencia de repetición de un hábito.
/// Los rawValue coinciden con los valores de tu enum SQL.
enum Frequency: String, Codable, CaseIterable {
    case daily  = "DAILY"
    case weekly = "WEEKLY"
    case custom = "CUSTOM"
    
    /// Nombre legible para mostrar en la UI
    var displayName: String {
        switch self {
        case .daily:  return "Diario"
        case .weekly: return "Semanal"
        case .custom: return "Personalizado"
        }
    }
    
    /// Icono SF Symbol correspondiente
    var iconName: String {
        switch self {
        case .daily:  return "sun.max"
        case .weekly: return "calendar"
        case .custom: return "slider.horizontal.3"
        }
    }
}

// MARK: - Modelo de hábito

@Model
class Habit {
    
    // MARK: - Identificación
    
    var id: String
    
    /// ID del usuario dueño (clave foránea)
    var userId: String
    
    /// Relación inversa con User
    var user: User?
    
    // MARK: - Datos del hábito
    
    /// Nombre del hábito (ej: "Beber 2L de agua")
    var name: String
    
    /// Descripción opcional del hábito
    /// Nota: usamos "habitDescription" porque "description" es
    /// una propiedad heredada de NSObject en Swift.
    var habitDescription: String?
    
    /// Disparador del hábito (ej: "Si me levanto por la mañana...")
    var trigger: String?
    
    // MARK: - Configuración
    
    /// Frecuencia: diario, semanal o personalizado
    var frequency: Frequency
    
    /// Color personalizado (hex string, ej: "#018ABE")
    var color: String?
    
    /// Nombre del icono SF Symbol
    var icon: String?
    
    // MARK: - Rachas y escudos
    
    /// Racha actual (días/semanas consecutivos)
    var currentStreak: Int
    
    /// Racha máxima histórica
    var maxStreak: Int
    
    /// Escudos disponibles para proteger la racha
    var shields: Int
    
    // MARK: - Timestamps
    
    var createdAt: Date
    
    // MARK: - Relaciones
    
    /// Historial de completados del hábito
    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
    var logs: [HabitLog]?
    
    /// Historial de uso de escudos
    @Relationship(deleteRule: .cascade, inverse: \ShieldUsage.habit)
    var shieldLogs: [ShieldUsage]?
    
    // MARK: - Inicializador
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        name: String,
        habitDescription: String? = nil,
        trigger: String? = nil,
        frequency: Frequency = .daily,
        color: String? = "#018ABE",
        icon: String? = "heart",
        currentStreak: Int = 0,
        maxStreak: Int = 0,
        shields: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.habitDescription = habitDescription
        self.trigger = trigger
        self.frequency = frequency
        self.color = color
        self.icon = icon
        self.currentStreak = currentStreak
        self.maxStreak = maxStreak
        self.shields = shields
        self.createdAt = createdAt
        self.logs = []
        self.shieldLogs = []
    }
    
    // MARK: - Propiedades computadas
    
    /// Color de SwiftUI listo para usar en vistas
    var swiftUIColor: Color {
        Color(hex: color ?? "#018ABE")
    }
    
    /// ¿Se completó hoy?
    var isCompletedToday: Bool {
        (logs ?? []).contains { Calendar.current.isDateInToday($0.completedAt) }
    }
}

// Necesitamos importar SwiftUI para la propiedad computada de Color
import SwiftUI
