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
    
    @AppStorage("currentBossLevel") private var currentBossLevel: Int = 1
    @AppStorage("damageMultiplier") private var damageMultiplier: Int = 1
    @AppStorage("extraDamageBomb") private var extraDamageBomb: Int = 0
    
    @State private var showingPaywall = false
    @State private var showingBossViewer = false
    
    private var currentEnemy: BossEnemy {
        BossSystem.enemy(forLevel: currentBossLevel)
    }
    
    // Cálculo de daño semanal (10 HP base por cada hábito completado en la semana * multiplicador + bombas compradas)
    private var completedThisWeekCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return habits.reduce(0) { total, habit in
            let logsThisWeek = (habit.logs ?? []).filter { $0.completedAt >= startOfWeek }
            return total + logsThisWeek.count
        }
    }
    
    private var totalBossHp: Int { currentEnemy.maxHp }
    private var habitDamage: Int { completedThisWeekCount * 10 * max(1, damageMultiplier) }
    private var totalDamage: Int { min(habitDamage + extraDamageBomb, totalBossHp) }
    private var currentBossHp: Int { max(totalBossHp - totalDamage, 0) }
    private var isBossDefeated: Bool { currentBossHp == 0 }
    private var isPro: Bool { user?.isPro ?? false }
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showingBossViewer = true
            } label: {
                HStack(spacing: Spacing.md) {
                    Image(currentEnemy.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentEnemy.name)
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                        Text("Enemigo \(currentBossLevel) de 6 · \(currentEnemy.phaseTitle)")
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: Spacing.sm)

                    Text("\(currentBossHp) HP")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(Color.secondary)

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            ProgressView(value: Double(currentBossHp), total: Double(max(totalBossHp, 1)))
                .tint(isBossDefeated ? Color.habSuccess : currentEnemy.swiftUIColor)
                .animation(.smooth(duration: 0.5), value: currentBossHp)

            HStack {
                Text(isBossDefeated ? "\(currentEnemy.name) derrotado" : "Completa hábitos para infligir daño")
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)

                Spacer()

                if isBossDefeated {
                    Button {
                        if !isPro {
                            showingPaywall = true
                        } else {
                            advanceToNextBoss()
                        }
                    } label: {
                        Text(currentBossLevel < 6 ? "Reclamar" : "Reclamar victoria")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.small)
                    .tint(Color.habPrimary)
                }
            }
        }
        .padding(Spacing.lg)
        .glassCard(Radius.lg)
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingBossViewer) {
            BossViewerSheet(habits: habits, user: user, onClaimReward: onClaimReward)
        }
    }

    private func advanceToNextBoss() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        onClaimReward()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            extraDamageBomb = 0
            if currentBossLevel < 6 {
                currentBossLevel += 1
            } else {
                currentBossLevel = 1
            }
        }
    }
}
