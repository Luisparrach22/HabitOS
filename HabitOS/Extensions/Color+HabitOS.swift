// ──────────────────────────────────────────────
// Color+HabitOS.swift — Extensión para crear colores desde hex
// ──────────────────────────────────────────────
// En React Native usas "#018ABE" directamente.
// En SwiftUI, Color no acepta hex de forma nativa,
// así que creamos este inicializador custom.
// Esto es lo que permite que `Color(hex: "#018ABE")` funcione.

import SwiftUI

extension Color {
    
    /// Crea un Color de SwiftUI a partir de un string hexadecimal.
    /// Soporta formatos: "#RRGGBB", "#RRGGBBAA", "RRGGBB"
    ///
    /// Ejemplo:
    /// ```swift
    /// let azul = Color(hex: "#018ABE")
    /// let rojo = Color(hex: "EF4444")
    /// ```
    init(hex: String) {
        // 1. Limpiamos el string: quitamos # y espacios
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // 2. Parseamos el valor hexadecimal
        var rgbValue: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgbValue)
        
        // 3. Extraemos los componentes R, G, B (y opcionalmente A)
        let red, green, blue, alpha: Double
        
        switch cleaned.count {
        case 6: // #RRGGBB
            red   = Double((rgbValue >> 16) & 0xFF) / 255.0
            green = Double((rgbValue >> 8)  & 0xFF) / 255.0
            blue  = Double( rgbValue        & 0xFF) / 255.0
            alpha = 1.0
        case 8: // #RRGGBBAA
            red   = Double((rgbValue >> 24) & 0xFF) / 255.0
            green = Double((rgbValue >> 16) & 0xFF) / 255.0
            blue  = Double((rgbValue >> 8)  & 0xFF) / 255.0
            alpha = Double( rgbValue        & 0xFF) / 255.0
        default:
            // Fallback: gris si el formato es inválido
            red = 0.5; green = 0.5; blue = 0.5; alpha = 1.0
        }
        
        // 4. Creamos el Color de SwiftUI
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}
