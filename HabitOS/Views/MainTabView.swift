// ──────────────────────────────────────────────
// MainTabView.swift — Contenedor Principal de Navegación
// ──────────────────────────────────────────────
// Estructura TabView en SwiftUI que maneja la barra inferior
// de pestañas de la aplicación. Equivale a tu layout (pestanas)
// en React Native/Expo Router.
// Mapea 3 pantallas: Dashboard (Hoy), Estadísticas y Perfil.

import SwiftUI

struct MainTabView: View {
    // Estado para controlar la pestaña seleccionada actualmente
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // PESTAÑA 1: Hoy (Dashboard de Hábitos)
            DashboardView()
                .tabItem {
                    Label("Mi Día", systemImage: "calendar")
                }
                .tag(0)
            
            // PESTAÑA 2: Estadísticas (Placeholder temporal premium)
            StatsPlaceholderView()
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar.xaxis")
                }
                .tag(1)
            
            // PESTAÑA 3: Perfil (Placeholder temporal premium)
            ProfilePlaceholderView()
                .tabItem {
                    Label("Perfil", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
        // Aplicamos el tinte de color de tu design system
        .tint(Color.habPrimary)
    }
}

// MARK: - Vistas de Relleno (Placeholders)

struct StatsPlaceholderView: View {
    var body: some View {
        ZStack {
            Color.habBackground.ignoresSafeArea()
            VStack(spacing: Spacing.md) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.habPrimary)
                
                Text("Estadísticas")
                    .font(.habTitle2)
                    .foregroundStyle(Color.habTextPrimary)
                    .fontWeight(.bold)
                
                Text("Próximamente en el Sprint 4.\nVisualiza tu progreso y rachas.")
                    .font(.habBody)
                    .foregroundStyle(Color.habTextMuted)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

struct ProfilePlaceholderView: View {
    var body: some View {
        ZStack {
            Color.habBackground.ignoresSafeArea()
            VStack(spacing: Spacing.md) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.habPrimary)
                
                Text("Perfil del Usuario")
                    .font(.habTitle2)
                    .foregroundStyle(Color.habTextPrimary)
                    .fontWeight(.bold)
                
                Text("Próximamente en el Sprint 4.\nSube de nivel, acumula XP y desbloquea escudos.")
                    .font(.habBody)
                    .foregroundStyle(Color.habTextMuted)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

// MARK: - Previsualización

#Preview {
    MainTabView()
}
