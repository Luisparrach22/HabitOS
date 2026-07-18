// ──────────────────────────────────────────────
// HabitColors.swift — Paleta de colores para hábitos
// ──────────────────────────────────────────────
// Mapeo directo de HABIT_COLORS y FREQUENCY_OPTIONS
// de tu iconos.ts de React Native.
// Estos colores se usan en el selector de color
// cuando el usuario crea o edita un hábito.

import SwiftUI

// MARK: - Colores de hábito

/// Un color seleccionable para personalizar un hábito.
/// Cada uno tiene un valor hex y un nombre legible.
struct HabitColor: Identifiable, Hashable {
    let id = UUID()
    let value: String   // Código hex, ej: "#018ABE"
    let label: String   // Nombre legible, ej: "Ocean"
    
    /// Convierte el hex a un Color de SwiftUI para usarlo en vistas.
    var color: Color {
        Color(hex: value)
    }
}

/// Paleta completa de colores disponibles para hábitos.
/// Coincide exactamente con tu HABIT_COLORS de iconos.ts.
let habitColors: [HabitColor] = [
    HabitColor(value: "#018ABE", label: "Ocean"),
    HabitColor(value: "#2DD4A8", label: "Mint"),
    HabitColor(value: "#F5A623", label: "Amber"),
    HabitColor(value: "#EF4444", label: "Coral"),
    HabitColor(value: "#8B5CF6", label: "Violet"),
    HabitColor(value: "#EC4899", label: "Rose"),
    HabitColor(value: "#06B6D4", label: "Cyan"),
    HabitColor(value: "#10B981", label: "Emerald"),
    HabitColor(value: "#F97316", label: "Orange"),
    HabitColor(value: "#6366F1", label: "Indigo"),
]

// MARK: - Iconos SF Symbols por categoría

/// Categorías de iconos usando SF Symbols (el sistema nativo de Apple).
/// En React Native usabas FontAwesome5. En iOS, SF Symbols es la
/// alternativa nativa: viene preinstalado, se adapta al tamaño del
/// texto y soporta modo oscuro automáticamente.
struct IconCategory: Identifiable {
    let id = UUID()
    let label: String
    let icons: [String]  // Nombres de SF Symbols
}

/// Catálogo de iconos organizados por categoría.
/// Usa nombres de SF Symbols en vez de FontAwesome.
/// Puedes explorar todos los iconos disponibles en:
/// https://developer.apple.com/sf-symbols/
let iconCategories: [IconCategory] = [
    IconCategory(label: "💪 Fitness", icons: [
        "figure.run", "dumbbell", "bicycle", "figure.pool.swim",
        "figure.walk", "figure.skiing.downhill", "figure.skating",
        "basketball", "football", "volleyball"
    ]),
    IconCategory(label: "🧘 Mindfulness", icons: [
        "brain.head.profile", "leaf", "hands.clap",
        "moon", "sun.max", "cloud.sun", "leaf.arrow.triangle.circlepath",
        "sparkles", "wind", "drop"
    ]),
    IconCategory(label: "🍎 Health", icons: [
        "heart", "drop", "carrot", "cup.and.saucer",
        "bed.double", "lungs", "pills",
        "cross.case", "stethoscope", "waveform.path.ecg"
    ]),
    IconCategory(label: "📚 Learning", icons: [
        "book", "book.fill", "graduationcap", "pencil",
        "laptopcomputer", "globe", "puzzlepiece",
        "lightbulb", "text.book.closed", "doc.text"
    ]),
    IconCategory(label: "🎨 Creative", icons: [
        "paintpalette", "paintbrush", "music.note", "guitars",
        "camera", "film", "mic", "headphones",
        "scissors", "theatermasks"
    ]),
    IconCategory(label: "🏠 Daily Life", icons: [
        "house", "shower.handheld", "fork.knife", "mug",
        "pawprint", "tree", "wallet.pass",
        "banknote", "washer", "fan"
    ]),
    IconCategory(label: "🚀 Productivity", icons: [
        "checklist", "calendar", "clock", "laptopcomputer",
        "envelope", "briefcase", "chart.line.uptrend.xyaxis",
        "target", "flag.checkered", "rocket"
    ]),
    IconCategory(label: "🤝 Social", icons: [
        "person.2", "bubble.left.and.bubble.right", "phone",
        "hand.raised", "heart.circle", "face.smiling",
        "star", "gift", "hand.thumbsup", "person.3"
    ]),
]

/// Lista plana de todos los iconos (para búsqueda rápida).
let allIcons: [String] = Array(Set(iconCategories.flatMap(\.icons)))

/// Iconos por defecto para la fila rápida al crear un hábito.
let defaultQuickIcons = [
    "heart", "book", "moon", "dumbbell", "brain.head.profile"
]
