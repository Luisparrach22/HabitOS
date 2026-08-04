// ──────────────────────────────────────────────
// MainTabView.swift — Contenedor Principal de Navegación
// ──────────────────────────────────────────────
// Estructura TabView en SwiftUI que maneja la barra inferior
// de pestañas de la aplicación. Mapea 3 pantallas principales:
// Dashboard (Hoy), Estadísticas y Perfil.

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Query private var users: [User]
    @Query private var habits: [Habit]
    
    // Estado para controlar la pestaña seleccionada actualmente
    @State private var selectedTab = 0
    @State private var showingCreateHabitSheet = false
    @State private var showingPaywall = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // PESTAÑA 1: Hoy (Dashboard de Hábitos)
            DashboardView()
                .tabItem {
                    Label(
                        "Mi Día",
                        systemImage: selectedTab == 0 ? "checkmark.circle.fill" : "checkmark.circle"
                    )
                }
                .tag(0)
            
            // PESTAÑA 2: Estadísticas (Swift Charts + Heatmap)
            StatsView()
                .tabItem {
                    Label(
                        "Estadísticas",
                        systemImage: selectedTab == 1 ? "chart.bar.fill" : "chart.bar"
                    )
                }
                .tag(1)
            
            // PESTAÑA 3: Perfil (Gamificación + XP + Logros)
            ProfileView()
                .tabItem {
                    Label(
                        "Perfil",
                        systemImage: selectedTab == 2 ? "person.crop.circle.fill" : "person.crop.circle"
                    )
                }
                .tag(2)
        }
        // Aplicamos el tinte de color de tu design system
        .tint(Color.habPrimary)
        .sheet(isPresented: $showingCreateHabitSheet) {
            CreateHabitView()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .onOpenURL { url in
            if url.scheme == "habitos" && (url.host == "create" || url.host == "nuevo" || url.absoluteString.contains("create")) {
                selectedTab = 0
                
                let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") ?? ""
                let currentUser = users.first(where: { $0.id == currentUserId }) ?? users.first
                let isPro = currentUser?.isPro ?? false
                let userHabitsCount = habits.filter { $0.userId == currentUser?.id }.count
                
                if !isPro && userHabitsCount >= 5 {
                    showingPaywall = true
                } else {
                    showingCreateHabitSheet = true
                }
            }
        }
    }
}

// MARK: - Previsualización
#Preview {
    MainTabView()
        .modelContainer(for: [Habit.self, HabitLog.self, User.self], inMemory: true)
}
