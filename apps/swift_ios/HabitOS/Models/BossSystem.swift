// ──────────────────────────────────────────────
// BossSystem.swift — Sistema de 6 Enemigos y Progresión RPG
// ──────────────────────────────────────────────
// Define las 6 fases de evolución del Monstruo de la Procrastinación,
// con vida (HP) creciente, nombres, títulos de fase y recompensas en XP.

import SwiftUI

struct BossEnemy: Identifiable, Equatable {
    let id: Int // 1 a 6
    let name: String
    let imageName: String
    let maxHp: Int
    let phaseTitle: String
    let description: String
    let rewardXP: Int
    let themeColorHex: String
    let accentColorHex: String
    
    var swiftUIColor: Color {
        Color(hex: themeColorHex)
    }
    var swiftUIAccentColor: Color {
        Color(hex: accentColorHex)
    }
}

struct BossSystem {
    
    static let enemies: [BossEnemy] = [
        BossEnemy(
            id: 1,
            name: "Monstruito de la Procrastinación",
            imageName: "boss_enemy_1",
            maxHp: 50,
            phaseTitle: "Fase 1: La Distracción Inicial",
            description: "Pequeño y amigable a simple vista, pero distrae tu atención con pequeños retrasos.",
            rewardXP: 100,
            themeColorHex: "#A855F7",
            accentColorHex: "#2DD4A8"
        ),
        BossEnemy(
            id: 2,
            name: "Guardián del Tiempo",
            imageName: "boss_enemy_2",
            maxHp: 100,
            phaseTitle: "Fase 2: El Ladrón de Minutos",
            description: "Equipado con un arnés de reloj de bolsillo y engranajes. Se alimenta de los minutos perdidos.",
            rewardXP: 200,
            themeColorHex: "#8B5CF6",
            accentColorHex: "#F5A623"
        ),
        BossEnemy(
            id: 3,
            name: "Acorazado del Tic-Tac",
            imageName: "boss_enemy_3",
            maxHp: 175,
            phaseTitle: "Fase 3: El Devorador de Horas",
            description: "Porta una torre de reloj de vapor en su espalda y engranajes dorados incrustados.",
            rewardXP: 300,
            themeColorHex: "#7C3AED",
            accentColorHex: "#FF9F0A"
        ),
        BossEnemy(
            id: 4,
            name: "Coloso de Engranajes",
            imageName: "boss_enemy_4",
            maxHp: 250,
            phaseTitle: "Fase 4: La Trampa de la Postergación",
            description: "Armado con una garra mecánica de presión y cañón de vapor en su hombro.",
            rewardXP: 450,
            themeColorHex: "#6D28D9",
            accentColorHex: "#EF4444"
        ),
        BossEnemy(
            id: 5,
            name: "Meca-Dragón del Caos",
            imageName: "boss_enemy_5",
            maxHp: 350,
            phaseTitle: "Fase 5: La Fortaleza del Retraso",
            description: "Protegido por placas de bronce de alta presión y manómetros de sobrecarga.",
            rewardXP: 600,
            themeColorHex: "#5B21B6",
            accentColorHex: "#EC4899"
        ),
        BossEnemy(
            id: 6,
            name: "Gran Señor de la Procrastinación",
            imageName: "boss_enemy_6",
            maxHp: 500,
            phaseTitle: "Fase Final: El Cronómetro Supremo",
            description: "La forma definitiva. Una fortaleza viviente con múltiples esferas de reloj de torre y cañones gemelos.",
            rewardXP: 1000,
            themeColorHex: "#4C1D95",
            accentColorHex: "#00F5D4"
        )
    ]
    
    /// Retorna el enemigo correspondiente a un nivel de jefe específico (1 a 6).
    static func enemy(forLevel level: Int) -> BossEnemy {
        let clampedIndex = max(0, min(level - 1, enemies.count - 1))
        return enemies[clampedIndex]
    }
}
