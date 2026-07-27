// ──────────────────────────────────────────────
// ProfileView.swift — Perfil de Usuario y Gamificación
// ──────────────────────────────────────────────
// Pantalla de usuario que incluye nivel actual, progreso de XP,
// inventario de escudos, muro de insignias y ajustes de la app.

import SwiftUI
import SwiftData

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
}

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var users: [User]
    @Query private var habits: [Habit]
    
    private var currentUser: User? {
        users.first
    }
    
    private var totalShieldsCount: Int {
        habits.reduce(0) { $0 + $1.shields }
    }
    
    // Lista de Insignias / Logros del Usuario
    private var achievements: [Achievement] {
        let totalXp = currentUser?.totalXp ?? 0
        let maxStreak = habits.map(\.maxStreak).max() ?? 0
        
        return [
            Achievement(title: "Primer Paso", description: "Completa tu primer hábito", icon: "sparkles", isUnlocked: totalXp > 0),
            Achievement(title: "Racha de 7 Días", description: "Mantén una racha de 1 semana", icon: "flame.fill", isUnlocked: maxStreak >= 7),
            Achievement(title: "Escudo Protector", description: "Usa un escudo para salvar tu racha", icon: "shield.fill", isUnlocked: totalShieldsCount > 0 || totalXp > 100),
            Achievement(title: "Nivel 5 Alcanzado", description: "Llega al nivel 5 de experiencia", icon: "crown.fill", isUnlocked: (currentUser?.level ?? 1) >= 5),
            Achievement(title: "Centurión", description: "Acumula 1,000 XP totales", icon: "medal.fill", isUnlocked: totalXp >= 1000)
        ]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.habBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        
                        // 1. Tarjeta Principal de Perfil y Nivel
                        VStack(spacing: Spacing.md) {
                            // Avatar con Badge de Nivel
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#7B2CBF"), Color(hex: "#00F5D4")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text(currentUser?.name?.prefix(1).uppercased() ?? "H")
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.white)
                                    )
                                
                                Text("Nv. \(currentUser?.level ?? 1)")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.habWarning)
                                    .cornerRadius(Radius.full)
                            }
                            
                            VStack(spacing: 2) {
                                Text(currentUser?.name ?? "Desarrollador HabitOS")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.primary)
                                
                                Text(currentUser?.email ?? "usuario@habitos.app")
                                    .font(.footnote)
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            // Barra de Progreso a Siguiente Nivel
                            let currentXP = GamificationEngine.xpInCurrentLevel(totalXP: currentUser?.totalXp ?? 0)
                            let xpLimit = GamificationEngine.xpPerLevel
                            let fraction = CGFloat(GamificationEngine.levelProgressFraction(totalXP: currentUser?.totalXp ?? 0))
                            
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                HStack {
                                    Text("Progreso de Nivel")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.secondary)
                                    Spacer()
                                    Text("\(currentXP) / \(xpLimit) XP")
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundStyle(Color.secondary)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.primary.opacity(0.04))
                                            .frame(height: 8)
                                        
                                        Capsule()
                                            .fill(Color.habPrimary)
                                            .frame(width: geometry.size.width * fraction, height: 8)
                                    }
                                }
                                .frame(height: 8)
                            }
                            .padding(.top, Spacing.sm)
                        }
                        .padding(18)
                        .background(Color.habCard)
                        .cornerRadius(Radius.xl2)
                        .shadow(color: Color.black.opacity(0.01), radius: 6, x: 0, y: 3)
                        
                        // 2. Inventario de Escudos
                        HStack(spacing: Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(Color.habPrimary.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.habPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Escudos de Protección")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.primary)
                                Text("Tienes \(totalShieldsCount) escudos activos en tus hábitos.")
                                    .font(.footnote)
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.habCard)
                        .cornerRadius(Radius.lg)
                        .shadow(color: Color.black.opacity(0.01), radius: 4, x: 0, y: 2)
                        
                        // 3. Rejilla de Insignias y Logros
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundStyle(Color.habWarning)
                                    .font(.subheadline)
                                Text("Insignias y Logros")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.primary)
                                Spacer()
                            }
                            
                            VStack(spacing: 0) {
                                ForEach(achievements) { badge in
                                    HStack(spacing: Spacing.md) {
                                        ZStack {
                                            Circle()
                                                .fill(badge.isUnlocked ? Color.habWarning.opacity(0.12) : Color.primary.opacity(0.04))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: badge.icon)
                                                .font(.system(size: 18))
                                                .foregroundStyle(badge.isUnlocked ? Color.habWarning : Color.secondary)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(badge.title)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(badge.isUnlocked ? Color.primary : Color.secondary)
                                            Text(badge.description)
                                                .font(.caption)
                                                .foregroundStyle(Color.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        if badge.isUnlocked {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.habSuccess)
                                        } else {
                                            Image(systemName: "lock.fill")
                                                .font(.caption2)
                                                .foregroundStyle(Color.secondary)
                                        }
                                    }
                                    .padding(.vertical, Spacing.sm)
                                    
                                    if badge.title != achievements.last?.title {
                                        Divider()
                                            .opacity(0.4)
                                    }
                                }
                            }
                        }
                        .padding(18)
                        .background(Color.habCard)
                        .cornerRadius(Radius.xl2)
                        .shadow(color: Color.black.opacity(0.01), radius: 6, x: 0, y: 3)
                        
                        // 4. Ajustes de la App
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("AJUSTES")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .padding(.horizontal, Spacing.xs)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Label("Notificaciones locales", systemImage: "bell.fill")
                                        .font(.body)
                                        .foregroundStyle(Color.primary)
                                    Spacer()
                                    Text("Activadas")
                                        .font(.footnote)
                                        .foregroundStyle(Color.habSuccess)
                                }
                                .padding(14)
                                
                                Divider()
                                    .opacity(0.5)
                                
                                HStack {
                                    Label("Zona Horaria", systemImage: "globe")
                                        .font(.body)
                                        .foregroundStyle(Color.primary)
                                    Spacer()
                                    Text(currentUser?.timezone ?? "UTC")
                                        .font(.footnote)
                                        .foregroundStyle(Color.secondary)
                                }
                                .padding(14)
                            }
                            .background(Color.habCard)
                            .cornerRadius(Radius.lg)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl3)
                }
            }
            .navigationTitle("Perfil")
        }
    }
}

// MARK: - Previsualización
#Preview {
    ProfileView()
        .modelContainer(for: [Habit.self, User.self], inMemory: true)
}
