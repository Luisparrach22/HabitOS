// ──────────────────────────────────────────────
// HabitLog.swift — Modelo SwiftData
// ──────────────────────────────────────────────
// Mapeo de la tabla SQL "HabitLog".
// Cada vez que el usuario marca un hábito como completado,
// se crea un registro aquí. Es el equivalente a un "check-in".
//
// ¿Por qué un modelo separado y no un booleano en Habit?
// Porque queremos historial completo:
// - Saber exactamente cuándo se completó cada día.
// - Poder mostrar gráficas de progreso.
// - Adjuntar notas opcionales a cada completado.

import Foundation
import SwiftData

@Model
class HabitLog {
    
    var id: String
    
    /// ID del hábito al que pertenece (clave foránea)
    var habitId: String
    
    /// Relación inversa con Habit
    var habit: Habit?
    
    /// Fecha y hora exacta del completado
    var completedAt: Date
    
    /// Valor del completado (por defecto 1).
    /// Útil si un hábito tiene metas cuantificables
    /// (ej: "Beber 8 vasos" → value podría ser el número de vasos).
    var value: Int
    
    /// Notas opcionales del usuario (ej: "Hoy me costó más de lo normal")
    var notes: String?
    
    init(
        id: String = UUID().uuidString,
        habitId: String,
        completedAt: Date = .now,
        value: Int = 1,
        notes: String? = nil
    ) {
        self.id = id
        self.habitId = habitId
        self.completedAt = completedAt
        self.value = value
        self.notes = notes
    }
}
