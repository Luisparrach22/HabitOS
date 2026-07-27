// ──────────────────────────────────────────────
// HabitOSWatchApp.swift — Entry Point de la App para watchOS
// ──────────────────────────────────────────────
// Punto de entrada principal para el Apple Watch.
// Configura la inyección del ModelContainer de SwiftData.

import SwiftUI
import SwiftData

@main
struct HabitOSWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchDashboardView()
        }
        // Registramos el contenedor unificado configurado para CloudKit
        .modelContainer(ModelContainer.shared)
    }
}
