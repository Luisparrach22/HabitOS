// ──────────────────────────────────────────────
// Theme.swift — HabitOS Design System
// ──────────────────────────────────────────────
// Tokens centralizados: colores, espaciado y radios.
// Equivalente a tu tema.ts de React Native.
// En SwiftUI, los colores se definen como extensiones de `Color`
// para poder usarlos directamente: Color.habBackground, etc.

import SwiftUI

// MARK: - Colores del Design System

extension Color {
    
    // ── Primarios ─────────────────────────────────
    /// Fondo principal de la app (Dinámico iOS nativo)
    static let habBackground    = Color(uiColor: .systemGroupedBackground)
    /// Color de acento principal (Vibrante y contrastante)
    static let habPrimary       = Color.dynamic(lightHex: "#018ABE", darkHex: "#30A2FF")
    /// Texto oscuro principal
    static let habTextDark      = Color.dynamic(lightHex: "#001B48", darkHex: "#1C1C1E")
    /// Azul profundo para acentos
    static let habAccentDeep    = Color.dynamic(lightHex: "#02457A", darkHex: "#0A84FF")
    /// Azul claro para elementos sutiles
    static let habBlueLight     = Color.dynamic(lightHex: "#97CADB", darkHex: "#5AC8F5")
    
    // ── Superficies ───────────────────────────────
    /// Fondo de tarjetas (Adaptativo nativo)
    static let habCard          = Color(uiColor: .secondarySystemGroupedBackground)
    /// Tarjeta atenuada (Adaptativo nativo)
    static let habCardMuted     = Color(uiColor: .tertiarySystemGroupedBackground)
    /// Tarjeta con fondo de acento
    static let habCardDeep      = Color.dynamic(lightHex: "#018ABE", darkHex: "#1E293B")
    
    // ── Texto ─────────────────────────────────────
    /// Texto principal (Soporta Dynamic Type y contraste)
    static let habTextPrimary   = Color.primary
    /// Texto secundario
    static let habTextSecondary = Color.secondary
    /// Texto atenuado
    static let habTextMuted     = Color.dynamic(lightHex: "#5A8A9E", darkHex: "#8E8E93")
    
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
