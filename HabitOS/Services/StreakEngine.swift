// ──────────────────────────────────────────────
// StreakEngine.swift — Motor de Cálculo de Rachas y Escudos
// ──────────────────────────────────────────────
// Centraliza el cálculo de rachas diarias y el consumo de escudos
// para mantener la disciplina del usuario.

import Foundation
import SwiftData

struct StreakEngine {
    
    // MARK: - Cálculo de Racha
    
    /// Recalcula la racha actual y máxima de un hábito basándose en sus registros de completado (HabitLog) y escudos usados (ShieldUsage).
    static func updateStreak(for habit: Habit) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Obtenemos todas las fechas completadas o protegidas por escudos
        var completedDates = Set<Date>()
        
        for log in habit.logs ?? [] {
            completedDates.insert(calendar.startOfDay(for: log.completedAt))
        }
        for shield in habit.shieldLogs ?? [] {
            completedDates.insert(calendar.startOfDay(for: shield.usedAt))
        }
        
        guard !completedDates.isEmpty else {
            habit.currentStreak = 0
            return
        }
        
        // 1. Racha Actual
        var currentStreakCount = 0
        var checkDate = today
        
        // Si hoy no se ha completado, empezamos a comprobar desde ayer
        if !completedDates.contains(today) {
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
                checkDate = yesterday
            }
        }
        
        // Contamos días consecutivos hacia atrás
        while completedDates.contains(checkDate) {
            currentStreakCount += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }
        
        habit.currentStreak = currentStreakCount
        
        // 2. Racha Máxima Histórica
        let sortedDates = completedDates.sorted()
        var maxStreakCount = 0
        var tempStreak = 0
        var lastDate: Date? = nil
        
        for date in sortedDates {
            if let prev = lastDate {
                let diff = calendar.dateComponents([.day], from: prev, to: date).day ?? 0
                if diff == 1 {
                    tempStreak += 1
                } else if diff > 1 {
                    tempStreak = 1
                }
            } else {
                tempStreak = 1
            }
            lastDate = date
            if tempStreak > maxStreakCount {
                maxStreakCount = tempStreak
            }
        }
        
        if habit.currentStreak > maxStreakCount {
            maxStreakCount = habit.currentStreak
        }
        
        habit.maxStreak = maxStreakCount
    }
    
    // MARK: - Protección de Escudos
    
    /// Verifica si se deben consumir escudos para días anteriores no completados.
    static func applyShieldIfAvailable(for habit: Habit, date: Date, reason: String = "Escudo automático por día no completado", context: ModelContext) -> Bool {
        guard habit.shields > 0 else { return false }
        
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        
        // Descontamos un escudo
        habit.shields -= 1
        
        // Registramos el uso del escudo
        let shieldUsage = ShieldUsage(habitId: habit.id, usedAt: targetDate, reason: reason)
        context.insert(shieldUsage)
        if habit.shieldLogs == nil {
            habit.shieldLogs = []
        }
        habit.shieldLogs?.append(shieldUsage)
        
        // Recalculamos racha
        updateStreak(for: habit)
        
        try? context.save()
        return true
    }
}
