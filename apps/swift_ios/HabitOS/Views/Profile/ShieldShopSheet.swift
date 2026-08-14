// ──────────────────────────────────────────────
// ShieldShopSheet.swift — Tienda de Experiencia (XP), Escudos y Potenciadores
// ──────────────────────────────────────────────
// Hoja modal que permite al usuario canjear su XP por Escudos de Racha,
// Multiplicadores de Daño 2X y Bombas de Impacto Directo (50 HP).

import SwiftUI
import SwiftData

struct ShieldShopSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let user: User
    let habits: [Habit]
    
    @AppStorage("damageMultiplier") private var damageMultiplier: Int = 1
    @AppStorage("extraDamageBomb") private var extraDamageBomb: Int = 0
    
    @State private var selectedTab: Int = 0 // 0: Escudos, 1: Potenciadores
    @State private var alertMessage: String? = nil
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.habBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Cabecera informativa de la tienda
                    VStack(spacing: Spacing.xs) {
                        HStack(spacing: 4) {
                            Text("Tu saldo disponible:")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            Text("\(user.totalXp) XP")
                                .font(.title3.bold())
                                .foregroundStyle(Color.habWarning)
                        }
                        .padding(.top, Spacing.md)
                        
                        // Selector de Categoría (Escudos vs Potenciadores)
                        Picker("Categoría", selection: $selectedTab) {
                            Text("🛡️ Escudos de Racha").tag(0)
                            Text("⚡ Potenciadores Boss").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.sm)
                    }
                    .padding(.bottom, Spacing.md)
                    .frame(maxWidth: .infinity)
                    .background(Color.habCard)
                    
                    Divider()
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: Spacing.lg) {
                            if selectedTab == 0 {
                                // ── SECCIÓN 1: ESCUDOS DE RACHA ──
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Protección de Racha")
                                            .font(.headline)
                                            .foregroundStyle(Color.primary)
                                        Text("Un escudo evita que pierdas tu racha activa si olvidas completar el hábito un día. Costo: \(GamificationEngine.shieldXPCost) XP.")
                                            .font(.caption)
                                            .foregroundStyle(Color.secondary)
                                    }
                                    .padding(.horizontal, Spacing.lg)
                                    .padding(.top, Spacing.md)
                                    
                                    if habits.isEmpty {
                                        VStack(spacing: Spacing.md) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.title)
                                                .foregroundStyle(Color.habWarning)
                                            Text("No tienes hábitos activos")
                                                .font(.headline)
                                        }
                                        .padding(.vertical, 40)
                                        .frame(maxWidth: .infinity)
                                    } else {
                                        ForEach(habits) { habit in
                                            Button {
                                                purchaseShield(for: habit)
                                            } label: {
                                                HStack(spacing: Spacing.md) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(habit.swiftUIColor.opacity(0.12))
                                                            .frame(width: 44, height: 44)
                                                        Image(systemName: habit.icon ?? "star.fill")
                                                            .foregroundStyle(habit.swiftUIColor)
                                                            .font(.system(size: 18, weight: .semibold))
                                                    }
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(habit.name)
                                                            .font(.subheadline.bold())
                                                            .foregroundStyle(Color.primary)
                                                        
                                                        Text("Escudos activos: \(habit.shields)")
                                                            .font(.caption)
                                                            .foregroundStyle(Color.secondary)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    HStack(spacing: 4) {
                                                        Text("\(GamificationEngine.shieldXPCost) XP")
                                                            .font(.caption.bold())
                                                        Image(systemName: "shield.fill")
                                                            .font(.caption2)
                                                    }
                                                    .foregroundStyle(Color.white)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(user.totalXp >= GamificationEngine.shieldXPCost ? Color.habPrimary : Color.gray.opacity(0.4))
                                                    .cornerRadius(Radius.md)
                                                }
                                                .padding(14)
                                                .background(Color.habCard)
                                                .cornerRadius(Radius.lg)
                                                .padding(.horizontal, Spacing.lg)
                                            }
                                            .disabled(user.totalXp < GamificationEngine.shieldXPCost)
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            } else {
                                // ── SECCIÓN 2: POTENCIADORES DE DAÑO AL MONSTRUO ──
                                VStack(alignment: .leading, spacing: Spacing.md) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Potenciadores de Ataque al Boss")
                                            .font(.headline)
                                            .foregroundStyle(Color.primary)
                                        Text("Aumenta el daño que infliges al Monstruo de la Procrastinación para avanzar de fase más rápido.")
                                            .font(.caption)
                                            .foregroundStyle(Color.secondary)
                                    }
                                    .padding(.horizontal, Spacing.lg)
                                    .padding(.top, Spacing.md)
                                    
                                    // Tarjeta 1: Multiplicador 2X
                                    Button {
                                        purchase2XBooster()
                                    } label: {
                                        HStack(spacing: Spacing.md) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(hex: "#8B5CF6").opacity(0.15))
                                                    .frame(width: 48, height: 48)
                                                Image(systemName: "bolt.shield.fill")
                                                    .font(.system(size: 22))
                                                    .foregroundStyle(Color(hex: "#8B5CF6"))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                HStack {
                                                    Text("Multiplicador 2X de Daño")
                                                        .font(.subheadline.bold())
                                                        .foregroundStyle(Color.primary)
                                                    
                                                    if damageMultiplier > 1 {
                                                        Text("ACTIVO")
                                                            .font(.system(size: 9, weight: .black))
                                                            .foregroundStyle(Color.white)
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 2)
                                                            .background(Color(hex: "#00F5D4"))
                                                            .cornerRadius(4)
                                                    }
                                                }
                                                
                                                Text("Cada hábito completado inflige 20 HP de daño (en vez de 10 HP).")
                                                    .font(.caption)
                                                    .foregroundStyle(Color.secondary)
                                                    .lineLimit(2)
                                            }
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 4) {
                                                Text("\(GamificationEngine.booster2XCost) XP")
                                                    .font(.caption.bold())
                                            }
                                            .foregroundStyle(Color.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                damageMultiplier > 1 ? Color.gray.opacity(0.4) : (user.totalXp >= GamificationEngine.booster2XCost ? Color(hex: "#8B5CF6") : Color.gray.opacity(0.4))
                                            )
                                            .cornerRadius(Radius.md)
                                        }
                                        .padding(14)
                                        .background(Color.habCard)
                                        .cornerRadius(Radius.lg)
                                        .padding(.horizontal, Spacing.lg)
                                    }
                                    .disabled(damageMultiplier > 1 || user.totalXp < GamificationEngine.booster2XCost)
                                    .buttonStyle(.plain)
                                    
                                    // Tarjeta 2: Bomba de Daño Directo (50 HP)
                                    Button {
                                        purchaseDamageBomb()
                                    } label: {
                                        HStack(spacing: Spacing.md) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(hex: "#FF3B30").opacity(0.15))
                                                    .frame(width: 48, height: 48)
                                                Image(systemName: "flame.fill")
                                                    .font(.system(size: 22))
                                                    .foregroundStyle(Color(hex: "#FF3B30"))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text("Bomba Explosiva (+50 HP)")
                                                    .font(.subheadline.bold())
                                                    .foregroundStyle(Color.primary)
                                                
                                                Text("Inflige un impacto instantáneo de 50 HP de daño directo al enemigo actual.")
                                                    .font(.caption)
                                                    .foregroundStyle(Color.secondary)
                                                    .lineLimit(2)
                                            }
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 4) {
                                                Text("\(GamificationEngine.bombCost) XP")
                                                    .font(.caption.bold())
                                            }
                                            .foregroundStyle(Color.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(user.totalXp >= GamificationEngine.bombCost ? Color(hex: "#FF3B30") : Color.gray.opacity(0.4))
                                            .cornerRadius(Radius.md)
                                        }
                                        .padding(14)
                                        .background(Color.habCard)
                                        .cornerRadius(Radius.lg)
                                        .padding(.horizontal, Spacing.lg)
                                    }
                                    .disabled(user.totalXp < GamificationEngine.bombCost)
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.bottom, Spacing.xl)
                    }
                }
            }
            .navigationTitle("Tienda de Recompensas XP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .font(.body)
                    .foregroundStyle(Color.habDanger)
                }
            }
            .alert("Tienda XP", isPresented: $showAlert) {
                Button("Aceptar", role: .cancel) { }
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }
    
    private func purchaseShield(for habit: Habit) {
        let success = GamificationEngine.purchaseShield(for: habit, user: user, context: modelContext)
        let generator = UINotificationFeedbackGenerator()
        if success {
            generator.notificationOccurred(.success)
            alertMessage = "¡Escudo protector asignado exitosamente a '\(habit.name)'!"
            showAlert = true
        } else {
            generator.notificationOccurred(.error)
        }
    }
    
    private func purchase2XBooster() {
        let success = GamificationEngine.purchaseDamageMultiplier(user: user, context: modelContext)
        let generator = UINotificationFeedbackGenerator()
        if success {
            generator.notificationOccurred(.success)
            alertMessage = "¡Potenciador 2X de Daño activado! Ahora tus hábitos infligen el doble de daño."
            showAlert = true
        } else {
            generator.notificationOccurred(.error)
        }
    }
    
    private func purchaseDamageBomb() {
        let success = GamificationEngine.purchaseDamageBomb(user: user, context: modelContext)
        let generator = UINotificationFeedbackGenerator()
        if success {
            generator.notificationOccurred(.success)
            alertMessage = "¡Bomba Explosiva detonada! Infligiste 50 HP de daño directo al enemigo."
            showAlert = true
        } else {
            generator.notificationOccurred(.error)
        }
    }
}

#Preview {
    ShieldShopSheet(user: User(email: "", passwordHash: ""), habits: [])
}
