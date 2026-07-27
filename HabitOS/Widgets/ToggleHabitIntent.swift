// ──────────────────────────────────────────────
// ToggleHabitIntent.swift — Intent Interactivo iOS 17+
// ──────────────────────────────────────────────
// Permite al usuario completar o desmarcar un hábito
// directamente desde el Widget de la pantalla de inicio
// sin necesidad de abrir la aplicación.

import AppIntents
import SwiftData
import Foundation

struct ToggleHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Completar Hábito"
    static var description: IntentDescription = IntentDescription("Marca o desmarca un hábito desde el widget de HabitOS.")
    
    // Identificador único del hábito a modificar
    @Parameter(title: "ID del Hábito")
    var habitIDString: String
    
    init() {
        self.habitIDString = ""
    }
    
    init(habitID: UUID) {
        self.habitIDString = habitID.uuidString
    }
    
    init(habitIDString: String) {
        self.habitIDString = habitIDString
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        guard !habitIDString.isEmpty else {
            return .result()
        }
        
        let targetId = habitIDString
        
        // Obtenemos el contenedor de SwiftData compartido
        let container = ModelContainer.shared
        let context = container.mainContext
        
        // Buscamos el hábito objetivo
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == targetId })
        guard let habit = try context.fetch(descriptor).first else {
            return .result()
        }
        
        // Cargar o crear el usuario activo
        let userDescriptor = FetchDescriptor<User>()
        let user: User
        if let existingUser = try context.fetch(userDescriptor).first {
            user = existingUser
        } else {
            let newUser = User(email: "hero@habitos.app", name: "Héroe", passwordHash: "local")
            context.insert(newUser)
            user = newUser
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let isAlreadyCompleted = (habit.logs ?? []).contains { calendar.isDate($0.completedAt, inSameDayAs: today) }
        
        if isAlreadyCompleted {
            // Desmarcar hábito del día
            if let logIndex = (habit.logs ?? []).firstIndex(where: { calendar.isDate($0.completedAt, inSameDayAs: today) }) {
                if habit.logs != nil {
                    let log = habit.logs!.remove(at: logIndex)
                    context.delete(log)
                }
                
                // Actualizar racha y deducir XP
                StreakEngine.updateStreak(for: habit)
                GamificationEngine.deductXPForUnchecking(habit: habit, user: user, context: context)
            }
        } else {
            // Marcar como completado
            let newLog = HabitLog(habitId: habit.id, completedAt: Date(), notes: "Completado desde Widget")
            if habit.logs == nil {
                habit.logs = []
            }
            habit.logs?.append(newLog)
            context.insert(newLog)
            
            // Recalcular racha y recompensar XP
            StreakEngine.updateStreak(for: habit)
            GamificationEngine.rewardXPForCompletion(habit: habit, user: user, context: context)
        }
        
        try context.save()
        return .result()
    }
}
