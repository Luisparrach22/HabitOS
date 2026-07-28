// ──────────────────────────────────────────────
// AvatarSystem.swift — Biblioteca de Avatares y Gradientes
// ──────────────────────────────────────────────
// Define los iconos de avatares (basados en emojis de alta resolución)
// y los gradientes de fondo premium que el usuario puede elegir.

import SwiftUI

struct AvatarOption: Identifiable, Equatable {
    let id: String
    let emoji: String
    let name: String
}

struct AvatarGradient: Identifiable, Equatable {
    let id: Int
    let colors: [Color]
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct AvatarSystem {
    
    // Lista de personajes y símbolos personalizables
    static let avatars: [AvatarOption] = [
        AvatarOption(id: "owl", emoji: "🦉", name: "Búho Disciplinado"),
        AvatarOption(id: "fox", emoji: "🦊", name: "Zorro Astuto"),
        AvatarOption(id: "cat", emoji: "🐱", name: "Gato Curioso"),
        AvatarOption(id: "bear", emoji: "🐻", name: "Oso Fuerte"),
        AvatarOption(id: "koala", emoji: "🐨", name: "Koala Relajado"),
        AvatarOption(id: "tiger", emoji: "🐯", name: "Tigre Enérgico"),
        AvatarOption(id: "panda", emoji: "🐼", name: "Panda Alegre"),
        AvatarOption(id: "penguin", emoji: "🐧", name: "Pingüino Constante"),
        AvatarOption(id: "dino", emoji: "🦖", name: "Dino Constante"),
        AvatarOption(id: "lion", emoji: "🦁", name: "León Valiente"),
        AvatarOption(id: "unicorn", emoji: "🦄", name: "Unicornio Enfocado"),
        AvatarOption(id: "robot", emoji: "🤖", name: "Robot Productivo"),
        AvatarOption(id: "alien", emoji: "👾", name: "Monstruito"),
        AvatarOption(id: "rocket", emoji: "🚀", name: "Cohete"),
        AvatarOption(id: "lightning", emoji: "⚡", name: "Rayo de XP")
    ]
    
    // Lista de gradientes de fondo premium
    static let gradients: [AvatarGradient] = [
        AvatarGradient(id: 0, colors: [Color(hex: "#7B2CBF"), Color(hex: "#00F5D4")]), // Púrpura a Cian
        AvatarGradient(id: 1, colors: [Color(hex: "#FF4D00"), Color(hex: "#FF9F00")]), // Naranja a Oro
        AvatarGradient(id: 2, colors: [Color(hex: "#2DD4A8"), Color(hex: "#018ABE")]), // Verde a Azul
        AvatarGradient(id: 3, colors: [Color(hex: "#EC4899"), Color(hex: "#7B2CBF")]), // Rosa a Púrpura
        AvatarGradient(id: 4, colors: [Color(hex: "#0A84FF"), Color(hex: "#30A2FF")]), // Azul a Celeste
        AvatarGradient(id: 5, colors: [Color(hex: "#FFCC00"), Color(hex: "#FF4D00")]), // Amarillo a Naranja
        AvatarGradient(id: 6, colors: [Color(hex: "#1E293B"), Color(hex: "#0F172A")])  // Gris Carbón (Oscuro)
    ]
    
    /// Parsea el string en formato "owl:0" y retorna la opción de avatar y su gradiente.
    static func parseAvatar(_ avatarString: String?) -> (option: AvatarOption, gradient: AvatarGradient) {
        let defaultValue = (avatars[0], gradients[0])
        guard let avatarString = avatarString, !avatarString.isEmpty else {
            return defaultValue
        }
        
        let parts = avatarString.split(separator: ":")
        guard parts.count == 2 else {
            return defaultValue
        }
        
        let avatarID = String(parts[0])
        let gradientID = Int(parts[1]) ?? 0
        
        let selectedOption = avatars.first(where: { $0.id == avatarID }) ?? avatars[0]
        let selectedGradient = gradients.first(where: { $0.id == gradientID }) ?? gradients[0]
        
        return (selectedOption, selectedGradient)
    }
}
