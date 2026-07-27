// ──────────────────────────────────────────────
// HabitOSWidgetBundle.swift — WidgetBundle Principal
// ──────────────────────────────────────────────
// Agrupa y exporta todos los widgets de la aplicación HabitOS.

import WidgetKit
import SwiftUI

struct HabitOSWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitDailyWidget()
        HabitStreakWidget()
    }
}
