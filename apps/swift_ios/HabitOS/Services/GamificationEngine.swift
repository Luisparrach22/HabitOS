// ──────────────────────────────────────────────
// GamificationEngine.swift — Motor de Gamificación y XP
// ──────────────────────────────────────────────
// Maneja la otorgación de puntos de experiencia (XP), el cálculo de niveles
// del usuario y las recompensas por hitos (ej. escudos por subir de nivel).

import Foundation
import SwiftData

struct LevelUpResult {
    let didLevelUp: Bool
    let oldLevel: Int
    let newLevel: Int
    let shieldsAwarded: Int
}

struct GamificationEngine {
    
    // Configuración de constantes del sistema
    static let baseXPPerCompletion = 50
    static let streakBonusFactor = 5 // +5 XP por día de racha
    static let xpPerLevel = 200
    static let shieldXPCost = 150
    static let booster2XCost = 200
    static let bombCost = 300
    
    // MARK: - Otorgar / Restar XP por Hábito
    
    /// Otorga XP al usuario por completar un hábito y verifica si subió de nivel.
    @discardableResult
    static func rewardXPForCompletion(habit: Habit, user: User, context: ModelContext) -> LevelUpResult {
        let streakBonus = habit.currentStreak * streakBonusFactor
        let earnedXP = baseXPPerCompletion + streakBonus
        
        let oldLevel = user.level
        user.totalXp += earnedXP
        
        let newLevel = calculateLevel(fromXP: user.totalXp)
        let didLevelUp = newLevel > oldLevel
        var shieldsAwarded = 0
        
        if didLevelUp {
            shieldsAwarded = newLevel - oldLevel
            user.level = newLevel
            // Otorgamos escudos al hábito si fue quien produjo el level up o al primer hábito activo
            habit.shields += shieldsAwarded
        }
        
        try? context.save()
        
        Task {
            try? await SupabaseService.shared.syncUser(user)
            if didLevelUp {
                try? await SupabaseService.shared.syncHabit(habit)
            }
        }
        
        return LevelUpResult(
            didLevelUp: didLevelUp,
            oldLevel: oldLevel,
            newLevel: newLevel,
            shieldsAwarded: shieldsAwarded
        )
    }
    
    /// Deduce XP en caso de que el usuario desmarque un hábito completado.
    static func deductXPForUnchecking(habit: Habit, user: User, context: ModelContext) {
        let streakBonus = habit.currentStreak * streakBonusFactor
        let xpToDeduct = baseXPPerCompletion + streakBonus
        
        user.totalXp = max(0, user.totalXp - xpToDeduct)
        user.level = calculateLevel(fromXP: user.totalXp)
        
        try? context.save()
        
        Task {
            try? await SupabaseService.shared.syncUser(user)
        }
    }
    
    /// Otorga una cantidad directa de XP de bonificación (ej. por misiones o pomodoro).
    static func addBonusXP(amount: Int, to user: User, context: ModelContext) {
        user.totalXp += amount
        user.level = calculateLevel(fromXP: user.totalXp)
        try? context.save()
        
        Task {
            try? await SupabaseService.shared.syncUser(user)
        }
    }
    
    /// Permite comprar un escudo para un hábito deduciendo XP al usuario y actualizando su nivel.
    @discardableResult
    static func purchaseShield(for habit: Habit, user: User, context: ModelContext) -> Bool {
        guard user.totalXp >= shieldXPCost else { return false }
        
        user.totalXp -= shieldXPCost
        user.level = calculateLevel(fromXP: user.totalXp)
        habit.shields += 1
        
        try? context.save()
        
        Task {
            try? await SupabaseService.shared.syncUser(user)
            try? await SupabaseService.shared.syncHabit(habit)
        }
        return true
    }
    
    /// Compra un multiplicador de daño 2X reduciendo XP al usuario.
    @discardableResult
    static func purchaseDamageMultiplier(user: User, context: ModelContext) -> Bool {
        guard user.totalXp >= booster2XCost else { return false }
        
        user.totalXp -= booster2XCost
        user.level = calculateLevel(fromXP: user.totalXp)
        
        UserDefaults.standard.set(2, forKey: "damageMultiplier")
        
        try? context.save()
        
        Task {
            try? await SupabaseService.shared.syncUser(user)
        }
        return true
    }
    
    /// Compra una bomba de daño directo (50 HP) reduciendo XP al usuario.
    @discardableResult
    static func purchaseDamageBomb(user: User, context: ModelContext) -> Bool {
        guard user.totalXp >= bombCost else { return false }
        
        user.totalXp -= bombCost
        user.level = calculateLevel(fromXP: user.totalXp)
        
        let currentBombDamage = UserDefaults.standard.integer(forKey: "extraDamageBomb")
        UserDefaults.standard.set(currentBombDamage + 50, forKey: "extraDamageBomb")
        
        try? context.save()
        
        Task {
            try? await SupabaseService.shared.syncUser(user)
        }
        return true
    }
    
    // MARK: - Cálculos de Nivel y Progreso
    
    /// Calcula el nivel actual basándose en la experiencia acumulada.
    static func calculateLevel(fromXP xp: Int) -> Int {
        return max(1, 1 + (xp / xpPerLevel))
    }
    
    /// XP total necesario para alcanzar el inicio del nivel dado.
    static func xpRequiredForLevel(_ level: Int) -> Int {
        return (level - 1) * xpPerLevel
    }
    
    /// Experiencia dentro del nivel actual (0 a 199 XP).
    static func xpInCurrentLevel(totalXP: Int) -> Int {
        return totalXP % xpPerLevel
    }
    
    /// Porcentaje de progreso dentro del nivel actual (0.0 a 1.0).
    static func levelProgressFraction(totalXP: Int) -> Double {
        let currentXP = xpInCurrentLevel(totalXP: totalXP)
        return Double(currentXP) / Double(xpPerLevel)
    }
}
