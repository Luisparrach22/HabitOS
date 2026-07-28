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
    @AppStorage("currentUserId") private var currentUserId: String = ""
    @AppStorage("appThemeMode") private var appThemeMode: String = "system"
    
    private var colorScheme: ColorScheme? {
        switch AppThemeMode(rawValue: appThemeMode) ?? .system {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                } else if currentUserId.isEmpty {
                    LoginView()
                } else {
                    MainTabView()
                        .onAppear {
                            Task {
                                await StoreManager.shared.checkActiveSubscriptions(modelContext: ModelContainer.shared.mainContext)
                            }
                        }
                }
            }
            .preferredColorScheme(colorScheme)
        }
        // Registramos el contenedor de SwiftData unificado e integrado con CloudKit y App Groups.
        .modelContainer(ModelContainer.shared)
    }
}
