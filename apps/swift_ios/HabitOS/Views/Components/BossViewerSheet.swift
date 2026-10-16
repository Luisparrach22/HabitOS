// ──────────────────────────────────────────────
// BossViewerSheet.swift — Visualizador 360° del Jefe Semanal
// ──────────────────────────────────────────────
// Vista inmersiva de videojuego para interactuar con el Monstruo de la Procrastinación en 3D.
// Modelo 3D recortado sin tarjeta de fondo, con pedestal luminoso, rotación 360° en 3D
// mediante gestos de arrastre y animaciones de impacto al tocarlo.

import SwiftUI
import SwiftData

struct BossViewerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let habits: [Habit]
    let user: User?
    let onClaimReward: () -> Void
    
    @AppStorage("currentBossLevel") private var currentBossLevel: Int = 1
    @AppStorage("damageMultiplier") private var damageMultiplier: Int = 1
    @AppStorage("extraDamageBomb") private var extraDamageBomb: Int = 0
    
    // ── Estado 3D y Gestos ──
    @State private var rotationY: Double = 0.0
    @State private var lastRotationY: Double = 0.0
    @State private var isFloatingUp: Bool = false
    
    // ── Estado de Ataque e Impacto ──
    @State private var isAttacking: Bool = false
    @State private var floatingDamageText: String? = nil
    @State private var floatingDamageOpacity: Double = 0.0
    @State private var floatingDamageOffset: CGFloat = 0.0
    
    @State private var showingPaywall = false
    @State private var showingShop = false
    
    private var currentEnemy: BossEnemy {
        BossSystem.enemy(forLevel: currentBossLevel)
    }
    
    // Cálculo de daño semanal (10 HP base por hábito completado * multiplicador + bombas de XP)
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
    private var damageDealt: Int { min(habitDamage + extraDamageBomb, totalBossHp) }
    private var currentBossHp: Int { max(totalBossHp - damageDealt, 0) }
    private var isBossDefeated: Bool { currentBossHp == 0 }
    private var isPro: Bool { user?.isPro ?? false }
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Enemigo \(currentBossLevel) de 6")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    Text(currentEnemy.name)
                        .font(.title2.weight(.semibold))
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.secondary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Cerrar")
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)

            Spacer()

            ZStack {
                Ellipse()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 200, height: 30)
                    .blur(radius: 8)
                    .offset(y: 135)
                    .scaleEffect(isFloatingUp ? 0.95 : 1.05)

                ZStack {
                    Image(currentEnemy.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 320, maxHeight: 290)
                        .scaleEffect(isAttacking ? 0.95 : 1.0)
                        .offset(y: isFloatingUp ? -8 : 2)
                        .rotation3DEffect(
                            Angle(degrees: rotationY),
                            axis: (x: 0.0, y: 1.0, z: 0.0),
                            perspective: 0.4
                        )
                        .onTapGesture {
                            triggerAttackImpact()
                        }
                        .accessibilityLabel(currentEnemy.name)

                    if let damageText = floatingDamageText {
                        Text(damageText)
                            .font(.headline)
                            .foregroundStyle(Color.secondary)
                            .offset(y: floatingDamageOffset)
                            .opacity(floatingDamageOpacity)
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            rotationY = lastRotationY + Double(value.translation.width * 0.8)
                        }
                        .onEnded { _ in
                            lastRotationY = rotationY
                        }
                )
            }
            .frame(height: 320)

            Text("Arrastra para girar")
                .font(.footnote)
                .foregroundStyle(Color.secondary)

            Spacer()

            VStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("Salud")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        Text("\(currentBossHp) / \(totalBossHp) HP")
                            .font(.subheadline.monospacedDigit())
                    }
                    ProgressView(value: Double(currentBossHp), total: Double(max(totalBossHp, 1)))
                        .tint(isBossDefeated ? Color.habSuccess : currentEnemy.swiftUIColor)
                        .animation(.smooth(duration: 0.5), value: currentBossHp)
                }

                Divider()

                LabeledContent("Daño infligido", value: "−\(damageDealt) HP")
                    .font(.subheadline)
                LabeledContent("Recompensa", value: "+\(currentEnemy.rewardXP) XP")
                    .font(.subheadline)

                if user != nil {
                    Button {
                        showingShop = true
                    } label: {
                        Label("Tienda XP", systemImage: "bag")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if isBossDefeated {
                    Button {
                        if !isPro {
                            showingPaywall = true
                        } else {
                            advanceToNextBoss()
                        }
                    } label: {
                        Text(isPro ? (currentBossLevel < 6 ? "Reclamar y continuar" : "Reclamar victoria final") : "Desbloquear con Pro")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color.habPrimary)
                }
            }
            .padding(Spacing.lg)
            .glassCard(Radius.xl)
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.lg)
        }
        .background { AuroraBackground() }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                isFloatingUp = true
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingShop) {
            if let user = user {
                ShieldShopSheet(user: user, habits: habits)
            }
        }
    }
    
    // MARK: - Efecto de Impacto al Tocar
    private func triggerAttackImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
            isAttacking = true
        }
        
        floatingDamageText = "Completa hábitos para atacar"
        floatingDamageOpacity = 1.0
        floatingDamageOffset = 0
        
        withAnimation(.easeOut(duration: 0.8)) {
            floatingDamageOffset = -60
            floatingDamageOpacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                isAttacking = false
            }
        }
    }
    
    private func advanceToNextBoss() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Otorgar bonificación de XP
        if let user = user {
            GamificationEngine.addBonusXP(amount: currentEnemy.rewardXP, to: user, context: modelContext)
        }
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
