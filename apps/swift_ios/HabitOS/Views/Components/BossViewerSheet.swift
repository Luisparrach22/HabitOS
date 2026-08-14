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
        ZStack {
            // Fondo de Arena Oscura de Neón en 3D
            Color.black
                .ignoresSafeArea()
            
            RadialGradient(
                colors: [
                    currentEnemy.swiftUIColor.opacity(0.3),
                    Color(hex: "#0F0B18"),
                    Color.black
                ],
                center: .center,
                startRadius: 5,
                endRadius: 320
            )
            .ignoresSafeArea()
            
            // Aura de Fuego y Luz del Boss
            RadialGradient(
                colors: [
                    currentEnemy.swiftUIColor.opacity(isBossDefeated ? 0.05 : 0.4),
                    currentEnemy.swiftUIAccentColor.opacity(0.2),
                    Color.clear
                ],
                center: .center,
                startRadius: 10,
                endRadius: 240
            )
            .ignoresSafeArea()
            
            VStack(spacing: Spacing.md) {
                
                // ── CABECERA Y BOTÓN CERRAR ──
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(currentEnemy.swiftUIAccentColor)
                                .frame(width: 8, height: 8)
                            Text("ENEMIGO FASE \(currentBossLevel) DE 6")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(currentEnemy.swiftUIAccentColor)
                                .kerning(1.2)
                        }
                        
                        Text(currentEnemy.name)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.white.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                
                Spacer()
                
                // ── ESCENA DEL PERSONAJE 3D REALISTA ──
                ZStack {
                    // Pedestal / Sombra 3D en el suelo
                    ZStack {
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        currentEnemy.swiftUIColor.opacity(0.5),
                                        currentEnemy.swiftUIAccentColor.opacity(0.3),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 110
                                )
                            )
                            .frame(width: 220, height: 40)
                            .blur(radius: 6)
                        
                        Ellipse()
                            .stroke(currentEnemy.swiftUIColor.opacity(0.6), lineWidth: 1.5)
                            .frame(width: 190, height: 34)
                    }
                    .offset(y: 135)
                    .scaleEffect(isFloatingUp ? 0.95 : 1.05)
                    
                    // Modelo 3D del Monstruo (Integrado transparente sin distorsión)
                    ZStack {
                        Image(currentEnemy.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 320, maxHeight: 290)
                            .scaleEffect(isAttacking ? 0.93 : 1.0)
                            .offset(y: isFloatingUp ? -8 : 2)
                            .rotation3DEffect(
                                Angle(degrees: rotationY),
                                axis: (x: 0.0, y: 1.0, z: 0.0),
                                perspective: 0.4
                            )
                            .onTapGesture {
                                triggerAttackImpact()
                            }
                        
                        // Texto Flotante al Tocar
                        if let damageText = floatingDamageText {
                            Text(damageText)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [currentEnemy.swiftUIAccentColor, Color(hex: "#FF9F0A")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .black, radius: 6)
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
                
                // Instrucción de interacción + Tienda de XP
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.draw.fill")
                            .font(.caption)
                        Text("Gira 360° • Completa hábitos para ganar Puntos de Ataque")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color.white.opacity(0.6))
                    
                    if let user = user {
                        Button {
                            showingShop = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "cart.fill")
                                Text("Tienda XP (Escudos & Potenciadores ⚡)")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(Color(hex: "#00F5D4"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(Radius.sm)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
                
                Spacer()
                
                // ── PANEL DE VIDA HP Y BATALLA ──
                VStack(spacing: Spacing.md) {
                    
                    // Barra de Vida HP Grande
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Text("SALUD DE \(currentEnemy.name.uppercased())")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.6))
                            
                            Spacer()
                            
                            Text("\(currentBossHp) / \(totalBossHp) HP")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(isBossDefeated ? Color(hex: "#00F5D4") : currentEnemy.swiftUIColor)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: Radius.sm)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 16)
                                
                                RoundedRectangle(cornerRadius: Radius.sm)
                                    .fill(
                                        LinearGradient(
                                            colors: isBossDefeated ? [Color(hex: "#00F5D4"), Color(hex: "#2DD4A8")] : [currentEnemy.swiftUIColor, currentEnemy.swiftUIAccentColor],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(currentBossHp) / CGFloat(totalBossHp), height: 16)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentBossHp)
                            }
                        }
                        .frame(height: 16)
                    }
                    
                    // Cuadrícula de Información del Monstruo
                    HStack(spacing: Spacing.sm) {
                        // Daño infligido
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Daño Infligido")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.5))
                            Text("-\(damageDealt) HP")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(Color(hex: "#FF9F0A"))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(Radius.md)
                        
                        // Recompensa en XP
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Recompensa de Fase")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.5))
                            Text("+\(currentEnemy.rewardXP) XP")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "#00F5D4"))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(Radius.md)
                    }
                    
                    // Botón de Recompensa y Siguiente Enemigo
                    if isBossDefeated {
                        Button {
                            if !isPro {
                                showingPaywall = true
                            } else {
                                advanceToNextBoss()
                            }
                        } label: {
                            HStack {
                                Image(systemName: isPro ? "bolt.fill" : "crown.fill")
                                Text(isPro ? (currentBossLevel < 6 ? "¡Reclamar y Desbloquear Enemigo \(currentBossLevel + 1)!" : "¡Victoria Final! Reclamar +1000 XP") : "Desbloquear Recompensas Pro")
                                    .font(.system(.body, design: .rounded).bold())
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#F5A623"), Color(hex: "#EC4899")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(Color.white)
                            .cornerRadius(Radius.md)
                            .shadow(color: Color(hex: "#F5A623").opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: Radius.xl2)
                        .fill(Color(hex: "#12131D"))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.xl2)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
            }
        }
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
        
        floatingDamageText = "¡Completa Hábitos! ⚡"
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
