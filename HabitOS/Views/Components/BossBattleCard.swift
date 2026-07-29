// ──────────────────────────────────────────────
// BossBattleCard.swift — Misión Semanal Boss Battle
// ──────────────────────────────────────────────
// Tarjeta interactiva de gamificación que presenta al "Jefe de la Procrastinación".
// Muestra el avatar 3D del monstruo y permite abrir el visualizador 360° al tocarlo.

import SwiftUI
import SwiftData

struct BossBattleCard: View {
    let habits: [Habit]
    let user: User?
    let onClaimReward: () -> Void
    
    @State private var showingPaywall = false
    @State private var showingBossViewer = false
    
    // Cálculo de daño semanal (10 HP por cada hábito completado en la semana)
    private var completedThisWeekCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return habits.reduce(0) { total, habit in
            let logsThisWeek = (habit.logs ?? []).filter { $0.completedAt >= startOfWeek }
            return total + logsThisWeek.count
        }
    }
    
    private var totalBossHp: Int { 100 }
    private var damageDealt: Int { min(completedThisWeekCount * 10, totalBossHp) }
    private var currentBossHp: Int { max(totalBossHp - damageDealt, 0) }
    private var isBossDefeated: Bool { currentBossHp == 0 }
    private var isPro: Bool { user?.isPro ?? false }
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            // Header del Boss (Tocar para ver 360°)
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                showingBossViewer = true
            } label: {
                HStack(spacing: Spacing.md) {
                    // Avatar Renderizado 3D del Monstruo con Aura
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: "#FF3B30"), Color(hex: "#8B5CF6")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 52, height: 52)
                            .shadow(color: Color(hex: "#FF3B30").opacity(0.5), radius: 8)
                        
                        Image("boss_procrastination_monster")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("Jefe Semanal")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "#FF3B30"))
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("\(currentBossHp) / \(totalBossHp) HP")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.9))
                                Image(systemName: "cube.transparent")
                                    .font(.caption2)
                                    .foregroundStyle(Color(hex: "#30A2FF"))
                            }
                        }
                        
                        Text("El Monstruo de la Procrastinación")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            
            // Barra de Vida Animada (También abre la vista 360° al tocarla)
            Button {
                showingBossViewer = true
            } label: {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .fill(
                                LinearGradient(
                                    colors: isBossDefeated ? [Color(hex: "#00F5D4"), Color(hex: "#2DD4A8")] : [Color(hex: "#FF3B30"), Color(hex: "#FF9F0A")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(currentBossHp) / CGFloat(totalBossHp), height: 12)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentBossHp)
                    }
                }
                .frame(height: 12)
            }
            .buttonStyle(.plain)
            
            // Pie de tarjeta y Estado
            HStack {
                Text(isBossDefeated ? "🎉 ¡Jefe Derrotado!" : "Toca para ver en 360° • Completa hábitos para hacer 10 HP de daño")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
                
                Spacer()
                
                if isBossDefeated {
                    Button {
                        if !isPro {
                            showingPaywall = true
                        } else {
                            onClaimReward()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Recompensas Pro")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                            Image(systemName: isPro ? "gift.fill" : "crown.fill")
                                .font(.caption2)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#F5A623"), Color(hex: "#EC4899")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(Radius.md)
                        .shadow(color: Color(hex: "#F5A623").opacity(0.4), radius: 6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Radius.xl)
                .fill(Color(hex: "#12141C"))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .stroke(
                            LinearGradient(
                                colors: isBossDefeated ? [Color(hex: "#00F5D4").opacity(0.6), Color(hex: "#8B5CF6").opacity(0.6)] : [Color(hex: "#FF3B30").opacity(0.3), Color.white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingBossViewer) {
            BossViewerSheet(habits: habits, user: user, onClaimReward: onClaimReward)
        }
    }
}
