// ──────────────────────────────────────────────
// Theme.swift — HabitOS Design System
// ──────────────────────────────────────────────
// Tokens centralizados: colores, espaciado y radios.
// Equivalente a tu tema.ts de React Native.
// En SwiftUI, los colores se definen como extensiones de `Color`
// para poder usarlos directamente: Color.habBackground, etc.

import SwiftUI

// MARK: - Colores del Design System

enum AppThemeMode: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "Sistema"
        case .light: return "Claro"
        case .dark: return "Oscuro"
        }
    }
}

enum GlobalTheme: String, CaseIterable, Identifiable {
    case original = "Original"
    case cyberpunk = "Cyberpunk"
    case minimalDark = "Minimal Dark"
    case sunsetWarm = "Sunset Warm"
    
    var id: String { self.rawValue }
    
    var isPremium: Bool {
        self != .original
    }
}

extension Color {
    
    private static var currentGlobalTheme: GlobalTheme {
        let name = UserDefaults.standard.string(forKey: "selectedGlobalTheme") ?? "Original"
        return GlobalTheme(rawValue: name) ?? .original
    }
    
    // ── Primarios ─────────────────────────────────
    /// Fondo principal de la app (Dinámico según tema global)
    static var habBackground: Color {
        switch currentGlobalTheme {
        case .original:
            return Color(uiColor: .systemGroupedBackground)
        case .cyberpunk:
            return Color.dynamic(lightHex: "#120E2E", darkHex: "#0B0813")
        case .minimalDark:
            return Color.dynamic(lightHex: "#F5F5F7", darkHex: "#000000")
        case .sunsetWarm:
            return Color.dynamic(lightHex: "#FFF5F5", darkHex: "#150F0F")
        }
    }
    
    /// Color de acento principal (Vibrante y contrastante)
    static var habPrimary: Color {
        switch currentGlobalTheme {
        case .original:
            return Color.dynamic(lightHex: "#018ABE", darkHex: "#30A2FF")
        case .cyberpunk:
            return Color.dynamic(lightHex: "#FF007F", darkHex: "#FF007F") // Rosa Neon
        case .minimalDark:
            return Color.dynamic(lightHex: "#000000", darkHex: "#FFFFFF") // Blanco/Negro
        case .sunsetWarm:
            return Color.dynamic(lightHex: "#FF5E36", darkHex: "#FF9F0A") // Naranja Atardecer
        }
    }
    
    /// Texto oscuro principal
    static var habTextDark: Color {
        switch currentGlobalTheme {
        case .minimalDark:
            return Color.dynamic(lightHex: "#000000", darkHex: "#FFFFFF")
        default:
            return Color.dynamic(lightHex: "#001B48", darkHex: "#1C1C1E")
        }
    }
    
    /// Azul profundo para acentos
    static var habAccentDeep: Color {
        switch currentGlobalTheme {
        case .original:
            return Color.dynamic(lightHex: "#02457A", darkHex: "#0A84FF")
        case .cyberpunk:
            return Color.dynamic(lightHex: "#9D4EDD", darkHex: "#7B2CBF") // Morado Neon
        case .minimalDark:
            return Color.dynamic(lightHex: "#333333", darkHex: "#E5E5EA")
        case .sunsetWarm:
            return Color.dynamic(lightHex: "#D9381E", darkHex: "#FF453A")
        }
    }
    
    /// Azul claro para elementos sutiles
    static var habBlueLight: Color {
        switch currentGlobalTheme {
        case .original:
            return Color.dynamic(lightHex: "#97CADB", darkHex: "#5AC8F5")
        case .cyberpunk:
            return Color.dynamic(lightHex: "#00F5D4", darkHex: "#00F5D4") // Cian Neon
        case .minimalDark:
            return Color.dynamic(lightHex: "#E5E5EA", darkHex: "#3A3A3C")
        case .sunsetWarm:
            return Color.dynamic(lightHex: "#FFD2C4", darkHex: "#FF9F0A")
        }
    }
    
    // ── Superficies ───────────────────────────────
    /// Fondo de tarjetas (Adaptativo)
    static var habCard: Color {
        switch currentGlobalTheme {
        case .original:
            return Color(uiColor: .secondarySystemGroupedBackground)
        case .cyberpunk:
            return Color.dynamic(lightHex: "#1A153E", darkHex: "#141026")
        case .minimalDark:
            return Color.dynamic(lightHex: "#FFFFFF", darkHex: "#1C1C1E")
        case .sunsetWarm:
            return Color.dynamic(lightHex: "#FFF0F0", darkHex: "#1E1515")
        }
    }
    
    /// Tarjeta atenuada (Adaptativo)
    static var habCardMuted: Color {
        switch currentGlobalTheme {
        case .original:
            return Color(uiColor: .tertiarySystemGroupedBackground)
        case .cyberpunk:
            return Color.dynamic(lightHex: "#241E4E", darkHex: "#1C1735")
        case .minimalDark:
            return Color.dynamic(lightHex: "#F2F2F7", darkHex: "#2C2C2E")
        case .sunsetWarm:
            return Color.dynamic(lightHex: "#FFE5E5", darkHex: "#2B1D1D")
        }
    }
    
    /// Tarjeta con fondo de acento
    static var habCardDeep: Color {
        switch currentGlobalTheme {
        case .original:
            return Color.dynamic(lightHex: "#018ABE", darkHex: "#1E293B")
        case .cyberpunk:
            return Color.dynamic(lightHex: "#FF007F", darkHex: "#1A153E")
        case .minimalDark:
            return Color.dynamic(lightHex: "#000000", darkHex: "#1C1C1E")
        case .sunsetWarm:
            return Color.dynamic(lightHex: "#FF5E36", darkHex: "#1E1515")
        }
    }
    
    // ── Texto ─────────────────────────────────────
    /// Texto principal (Soporta Dynamic Type y contraste)
    static let habTextPrimary   = Color.primary
    /// Texto secundario
    static let habTextSecondary = Color.secondary
    
    /// Texto atenuado
    static var habTextMuted: Color {
        switch currentGlobalTheme {
        case .minimalDark:
            return Color.dynamic(lightHex: "#8E8E93", darkHex: "#8E8E93")
        default:
            return Color.dynamic(lightHex: "#5A8A9E", darkHex: "#8E8E93")
        }
    }
    
    // ── Estados ───────────────────────────────────
    /// Éxito / hábito completado
    static let habSuccess       = Color.dynamic(lightHex: "#21AF4B", darkHex: "#34C759")
    /// Advertencia
    static let habWarning       = Color.dynamic(lightHex: "#F5A623", darkHex: "#FF9F0A")
    /// Error / eliminar
    static let habDanger        = Color.dynamic(lightHex: "#EF4444", darkHex: "#FF453A")
    
    // ── Bordes ────────────────────────────────────
    /// Borde estándar
    static let habBorder        = Color(uiColor: .separator)
    /// Borde sutil, semitransparente
    static let habBorderLight   = Color.primary.opacity(0.08)
}

// MARK: - Espaciado

/// Tokens de espaciado consistentes en toda la app.
/// Uso: `.padding(.horizontal, Spacing.lg)`
enum Spacing {
    static let xs:   CGFloat = 4
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 20
    static let xl2:  CGFloat = 24
    static let xl3:  CGFloat = 32
    static let xl4:  CGFloat = 40
}

// MARK: - Radios de borde

/// Tokens de radio para esquinas redondeadas.
/// Uso: `.cornerRadius(Radius.xl)`
enum Radius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 20
    static let xl2:  CGFloat = 24
    static let full: CGFloat = 9999
}
