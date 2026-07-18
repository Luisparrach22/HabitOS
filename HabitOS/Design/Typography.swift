// ──────────────────────────────────────────────
// Typography.swift — Fuentes custom Outfit
// ──────────────────────────────────────────────
// Mapeo directo de tu typography en tema.ts.
// En SwiftUI, las fuentes custom se cargan con Font.custom().
//
// IMPORTANTE para Xcode:
// 1. Arrastra los .ttf de Resources/Fonts/ al proyecto de Xcode.
// 2. Marca "Copy items if needed" y "Add to target: HabitOS".
// 3. En Info.plist, añade la clave "Fonts provided by application"
//    con estos valores:
//    - Outfit-Regular.ttf
//    - Outfit-Medium.ttf
//    - Outfit-SemiBold.ttf
//    - Outfit-Bold.ttf

import SwiftUI

// MARK: - Nombres internos de las fuentes

/// Los nombres exactos de los archivos .ttf que registramos.
/// Si una fuente no se encuentra, SwiftUI usará la del sistema como fallback.
private enum OutfitFont {
    static let regular  = "Outfit-Regular"
    static let medium   = "Outfit-Medium"
    static let semiBold = "Outfit-SemiBold"
    static let bold     = "Outfit-Bold"
}

// MARK: - Escala tipográfica

/// Sistema tipográfico de HabitOS basado en la fuente Outfit.
/// Cada estilo mapea directamente a un nivel de tu tema.ts.
///
/// Uso:
/// ```swift
/// Text("Mis Hábitos")
///     .font(.habLargeTitle)
/// ```
extension Font {
    
    // ── Títulos ───────────────────────────────────
    
    /// 32pt Bold — Títulos principales de pantalla
    static let habLargeTitle = Font.custom(OutfitFont.bold, size: 32)
    
    /// 26pt Bold — Títulos de sección
    static let habTitle1 = Font.custom(OutfitFont.bold, size: 26)
    
    /// 22pt SemiBold — Subtítulos
    static let habTitle2 = Font.custom(OutfitFont.semiBold, size: 22)
    
    /// 18pt SemiBold — Títulos de tarjeta
    static let habTitle3 = Font.custom(OutfitFont.semiBold, size: 18)
    
    // ── Cuerpo ────────────────────────────────────
    
    /// 16pt SemiBold — Encabezados inline
    static let habHeadline = Font.custom(OutfitFont.semiBold, size: 16)
    
    /// 15pt Regular — Texto principal del cuerpo
    static let habBody = Font.custom(OutfitFont.regular, size: 15)
    
    /// 14pt Regular — Texto de llamada a la acción o secundario
    static let habCallout = Font.custom(OutfitFont.regular, size: 14)
    
    // ── Pequeños ──────────────────────────────────
    
    /// 13pt Medium — Subtexto / labels
    static let habSubhead = Font.custom(OutfitFont.medium, size: 13)
    
    /// 12pt Regular — Notas al pie
    static let habFootnote = Font.custom(OutfitFont.regular, size: 12)
    
    /// 11pt Medium — Captions en mayúsculas
    static let habCaption = Font.custom(OutfitFont.medium, size: 11)
}
