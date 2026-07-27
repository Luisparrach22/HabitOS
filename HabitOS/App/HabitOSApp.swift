// ──────────────────────────────────────────────
// HabitOSApp.swift — Entry Point de la aplicación
// ──────────────────────────────────────────────
// Es el PRIMER archivo que se ejecuta al abrir la app.
// Configura SwiftData y decide si mostrar el Onboarding inicial
// o la navegación principal MainTabView.

import SwiftUI
import SwiftData

@main
struct HabitOSApp: App {
    
    // Estado persistido localmente para detectar primer inicio
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        // Registramos TODOS nuestros modelos SwiftData aquí.
        .modelContainer(for: [
            User.self,
            Habit.self,
            HabitLog.self,
            ShieldUsage.self
        ])
    }
}
