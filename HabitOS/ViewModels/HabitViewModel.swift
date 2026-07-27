// ──────────────────────────────────────────────
// HabitViewModel.swift — ViewModel Centralizado de Hábitos
// ──────────────────────────────────────────────
// Gestiona las operaciones de hábitos, integración con el usuario,
// invocación a los motores de Rachas, Gamificación y Notificaciones.

import Foundation
import SwiftUI
import SwiftData

@Observable
final class HabitViewModel {
    
    // Estado para notificar subidas de nivel a las vistas
    var lastLevelUpResult: LevelUpResult?
    var showLevelUpAlert: Bool = false
    
    // MARK: - Iniciar / Asegurar Usuario Existente
    
    /// Asegura que siempre exista al menos un perfil de usuario local en SwiftData.
    @discardableResult
    func ensureDefaultUser(context: ModelContext) -> User {
        let descriptor = FetchDescriptor<User>()
        if let existingUser = (try? context.fetch(descriptor))?.first {
            return existingUser
        }
        
        let newUser = User(
            email: "usuario@habitos.app",
            name: "Desarrollador",
            passwordHash: "local_hash",
            avatarUrl: nil,
            totalXp: 0,
            level: 1,
            timezone: TimeZone.current.identifier
        )
        context.insert(newUser)
        try? context.save()
        return newUser
    }
    
    // MARK: - Marcar / Desmarcar Completado
    
    /// Alterna el estado de completado de un hábito para el día de hoy con recálculo de racha y XP.
    func toggleCompletion(for habit: Habit, user: User?, context: ModelContext) {
        let calendar = Calendar.current
        
        if habit.isCompletedToday {
            // Desmarcar: eliminar el log de hoy
            if let todayLog = (habit.logs ?? []).first(where: { calendar.isDateInToday($0.completedAt) }) {
                context.delete(todayLog)
                if let index = (habit.logs ?? []).firstIndex(where: { $0.id == todayLog.id }) {
                    habit.logs?.remove(at: index)
                }
            }
            
            // Recalcular racha y reducir XP
            StreakEngine.updateStreak(for: habit)
            if let currentUser = user {
                GamificationEngine.deductXPForUnchecking(habit: habit, user: currentUser, context: context)
            }
        } else {
            // Marcar: crear nuevo log
            let newLog = HabitLog(habitId: habit.id)
            context.insert(newLog)
            if habit.logs == nil {
                habit.logs = []
            }
            habit.logs?.append(newLog)
            
            // Recalcular racha y otorgar XP
            StreakEngine.updateStreak(for: habit)
            if let currentUser = user {
                let result = GamificationEngine.rewardXPForCompletion(habit: habit, user: currentUser, context: context)
                if result.didLevelUp {
                    self.lastLevelUpResult = result
                    self.showLevelUpAlert = true
                }
            }
        }
        
        try? context.save()
    }
    
    // MARK: - Uso de Escudos
    
    /// Aplica un escudo a un hábito para proteger una racha.
    func protectHabitWithShield(habit: Habit, date: Date = Date(), context: ModelContext) -> Bool {
        return StreakEngine.applyShieldIfAvailable(for: habit, date: date, context: context)
    }
}
