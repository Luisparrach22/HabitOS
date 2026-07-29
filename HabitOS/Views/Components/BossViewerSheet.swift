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
    
    let habits: [Habit]
    let user: User?
    let onClaimReward: () -> Void
    
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
        ZStack {
            // Fondo de Arena Oscura de Neón en 3D
            Color.black
                .ignoresSafeArea()
            
            RadialGradient(
                colors: [
                    Color(hex: "#1E1B38"),
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
                    Color(hex: "#FF3B30").opacity(isBossDefeated ? 0.05 : 0.35),
                    Color(hex: "#8B5CF6").opacity(0.15),
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
                                .fill(Color(hex: "#FF3B30"))
                                .frame(width: 8, height: 8)
                            Text("BATALLA EN VIVO 3D")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(Color(hex: "#FF3B30"))
                                .kerning(1.2)
                        }
                        
                        Text("Monstruo de la Procrastinación")
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
                                        Color(hex: "#FF3B30").opacity(0.4),
                                        Color(hex: "#8B5CF6").opacity(0.2),
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
                            .stroke(Color(hex: "#FF3B30").opacity(0.5), lineWidth: 1.5)
                            .frame(width: 190, height: 34)
                    }
                    .offset(y: 135)
                    .scaleEffect(isFloatingUp ? 0.95 : 1.05)
                    
                    // Modelo 3D del Monstruo (Integrado sin marco de tarjeta)
                    ZStack {
                        Image("boss_procrastination_monster")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 310)
                            .blendMode(.screen) // Elimina cualquier fondo oscuro y deja solo al personaje 3D
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
                        
                        // Texto Flotante de Daño al Tocar
                        if let damageText = floatingDamageText {
                            Text(damageText)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#FF3B30"), Color(hex: "#FF9F0A")],
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
                
                // Instrucción de interacción
                HStack(spacing: 6) {
                    Image(systemName: "hand.draw.fill")
                        .font(.caption)
                    Text("Gira el personaje 360°  •  Toca el modelo 3D para atacar")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.white.opacity(0.6))
                .padding(.vertical, 4)
                
                Spacer()
                
                // ── PANEL DE VIDA HP Y BATALLA ──
                VStack(spacing: Spacing.md) {
                    
                    // Barra de Vida HP Grande
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Text("SALUD DEL JEFE (HP)")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.6))
                            
                            Spacer()
                            
                            Text("\(currentBossHp) / \(totalBossHp) HP")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(isBossDefeated ? Color(hex: "#00F5D4") : Color(hex: "#FF3B30"))
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: Radius.sm)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 16)
                                
                                RoundedRectangle(cornerRadius: Radius.sm)
                                    .fill(
                                        LinearGradient(
                                            colors: isBossDefeated ? [Color(hex: "#00F5D4"), Color(hex: "#2DD4A8")] : [Color(hex: "#FF3B30"), Color(hex: "#FF9F0A")],
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
                            Text("Daño Realizado")
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
                        
                        // Debilidad
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Debilidad Principal")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.5))
                            Text("Hábitos Diarios")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "#30A2FF"))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(Radius.md)
                    }
                    
                    // Botón de Recompensa
                    if isBossDefeated {
                        Button {
                            if !isPro {
                                showingPaywall = true
                            } else {
                                onClaimReward()
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Image(systemName: isPro ? "gift.fill" : "crown.fill")
                                Text(isPro ? "¡Reclamar Recompensa Semanal!" : "Recompensas Exclusivas Pro")
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
    }
    
    // MARK: - Efecto de Impacto al Tocar
    private func triggerAttackImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
            isAttacking = true
        }
        
        floatingDamageText = "-10 HP!"
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
}
