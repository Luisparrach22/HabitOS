// ──────────────────────────────────────────────
// ShieldUsage.swift — Modelo SwiftData
// ──────────────────────────────────────────────
// Mapeo de la tabla SQL "ShieldUsage".
// Un escudo protege la racha cuando el usuario no completa
// un hábito. Cada vez que se usa un escudo, se registra aquí.
//
// Mecánica de gamificación:
// - El usuario gana escudos al subir de nivel o completar rachas largas.
// - Si un día no completa un hábito, puede "gastar" un escudo
//   para mantener la racha viva.
// - Este modelo guarda el historial de cuándo y por qué se usó cada uno.

import Foundation
import SwiftData

@Model
class ShieldUsage {
    
    @Attribute(.unique)
    var id: String
    
    /// ID del hábito que fue protegido
    var habitId: String
    
    /// Relación inversa con Habit
    var habit: Habit?
    
    /// Fecha en que se usó el escudo
    var usedAt: Date
    
    /// Razón por la que se usó (opcional, ej: "Estuve enfermo")
    var reason: String?
    
    init(
        id: String = UUID().uuidString,
        habitId: String,
        usedAt: Date = .now,
        reason: String? = nil
    ) {
        self.id = id
        self.habitId = habitId
        self.usedAt = usedAt
        self.reason = reason
    }
}
