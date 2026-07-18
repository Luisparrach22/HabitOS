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
    /// Fondo principal de la app (#D6E8EE)
    static let habBackground    = Color(hex: "#D6E8EE")
    /// Color de acento principal (#018ABE)
    static let habPrimary       = Color(hex: "#018ABE")
    /// Texto oscuro principal (#001B48)
    static let habTextDark      = Color(hex: "#001B48")
    /// Azul profundo para acentos (#02457A)
    static let habAccentDeep    = Color(hex: "#02457A")
    /// Azul claro para elementos sutiles (#97CADB)
    static let habBlueLight     = Color(hex: "#97CADB")
    
    // ── Superficies ───────────────────────────────
    /// Fondo de tarjetas (#FFFFFF)
    static let habCard          = Color.white
    /// Tarjeta atenuada (#EFF7FA)
    static let habCardMuted     = Color(hex: "#EFF7FA")
    /// Tarjeta con fondo de acento (#018ABE)
    static let habCardDeep      = Color(hex: "#018ABE")
    
    // ── Texto ─────────────────────────────────────
    /// Texto principal (#001B48)
    static let habTextPrimary   = Color(hex: "#001B48")
    /// Texto secundario (#02457A)
    static let habTextSecondary = Color(hex: "#02457A")
    /// Texto atenuado (#5A8A9E)
    static let habTextMuted     = Color(hex: "#5A8A9E")
    
    // ── Estados ───────────────────────────────────
    /// Éxito / hábito completado (#21AF4B)
    static let habSuccess       = Color(hex: "#21AF4B")
    /// Advertencia (#F5A623)
    static let habWarning       = Color(hex: "#F5A623")
    /// Error / eliminar (#EF4444)
    static let habDanger        = Color(hex: "#EF4444")
    
    // ── Bordes ────────────────────────────────────
    /// Borde estándar (#D6E8EE)
    static let habBorder        = Color(hex: "#D6E8EE")
    /// Borde sutil, semitransparente
    static let habBorderLight   = Color(hex: "#018ABE").opacity(0.15)
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
