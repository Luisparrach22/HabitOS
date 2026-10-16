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
            List {
                Section {
                    Picker("Categoría", selection: $selectedTab) {
                        Text("Escudos").tag(0)
                        Text("Potenciadores").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                } footer: {
                    Text("Saldo disponible: \(user.totalXp) XP")
                }

                if selectedTab == 0 {
                    Section {
                        if habits.isEmpty {
                            ContentUnavailableView("Sin hábitos activos", systemImage: "shield")
                        } else {
                            ForEach(habits) { habit in
                                shopRow(
                                    icon: habit.icon ?? "star.fill",
                                    color: habit.swiftUIColor,
                                    title: habit.name,
                                    subtitle: "Escudos activos: \(habit.shields)",
                                    cost: GamificationEngine.shieldXPCost,
                                    enabled: user.totalXp >= GamificationEngine.shieldXPCost
                                ) { purchaseShield(for: habit) }
                            }
                        }
                    } footer: {
                        Text("Un escudo evita que pierdas tu racha si olvidas completar el hábito un día.")
                    }
                    .glassListRow()
                } else {
                    Section {
                        shopRow(
                            icon: "bolt.fill",
                            color: .habPrimary,
                            title: damageMultiplier > 1 ? "Multiplicador 2X · Activo" : "Multiplicador 2X",
                            subtitle: "Cada hábito inflige 20 HP en vez de 10.",
                            cost: GamificationEngine.booster2XCost,
                            enabled: damageMultiplier <= 1 && user.totalXp >= GamificationEngine.booster2XCost
                        ) { purchase2XBooster() }

                        shopRow(
                            icon: "flame.fill",
                            color: .habDanger,
                            title: "Bomba (+50 HP)",
                            subtitle: "Daño directo e instantáneo al enemigo actual.",
                            cost: GamificationEngine.bombCost,
                            enabled: user.totalXp >= GamificationEngine.bombCost
                        ) { purchaseDamageBomb() }
                    } footer: {
                        Text("Avanza de fase más rápido contra el jefe semanal.")
                    }
                    .glassListRow()
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background { AuroraBackground() }
            .tint(Color.habPrimary)
            .navigationTitle("Tienda XP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .alert("Tienda XP", isPresented: $showAlert) {
                Button("Aceptar", role: .cancel) { }
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private func shopRow(icon: String, color: Color, title: String, subtitle: String, cost: Int, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .glassEffect(.regular.tint(color.opacity(0.75)), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundStyle(Color.primary)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                }

                Spacer(minLength: Spacing.sm)

                Text("\(cost) XP")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(enabled ? Color.habPrimary : Color.secondary)
            }
        }
        .disabled(!enabled)
    }
    
    private func purchaseShield(for habit: Habit) {
        let success = GamificationEngine.purchaseShield(for: habit, user: user, context: modelContext)
        let generator = UINotificationFeedbackGenerator()
        if success {
            generator.notificationOccurred(.success)
            alertMessage = "Escudo asignado a «\(habit.name)»."
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
            alertMessage = "Potenciador 2X activado."
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
            alertMessage = "Bomba lanzada: 50 HP de daño directo."
            showAlert = true
        } else {
            generator.notificationOccurred(.error)
        }
    }
}

#Preview {
    ShieldShopSheet(user: User(email: "", passwordHash: ""), habits: [])
}
