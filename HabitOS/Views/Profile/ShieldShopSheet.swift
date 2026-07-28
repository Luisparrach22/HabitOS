// ──────────────────────────────────────────────
// ShieldShopSheet.swift — Tienda de Escudos
// ──────────────────────────────────────────────
// Hoja modal que lista los hábitos del usuario y le permite
// comprar un escudo protector asignado al hábito elegido usando 150 XP.

import SwiftUI
import SwiftData

struct ShieldShopSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let user: User
    let habits: [Habit]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.habBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Cabecera informativa de la tienda
                    VStack(spacing: Spacing.sm) {
                        ZStack {
                            Circle()
                                .fill(Color.habPrimary.opacity(0.12))
                                .frame(width: 72, height: 72)
                            Image(systemName: "shield.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Color.habPrimary)
                        }
                        .padding(.top, Spacing.lg)
                        
                        Text("Tienda de Escudos")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.primary)
                        
                        Text("Costo: \(GamificationEngine.shieldXPCost) XP por escudo")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                        
                        HStack(spacing: 4) {
                            Text("Tu saldo actual:")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                            Text("\(user.totalXp) XP")
                                .font(.footnote.bold())
                                .foregroundStyle(Color.habWarning)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.primary.opacity(0.04))
                        .cornerRadius(Radius.sm)
                        .padding(.top, 2)
                    }
                    .padding(.bottom, Spacing.lg)
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .opacity(0.5)
                    
                    if habits.isEmpty {
                        // Sin hábitos
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title)
                                .foregroundStyle(Color.habWarning)
                            Text("No tienes hábitos activos")
                                .font(.headline)
                            Text("Crea al menos un hábito para poder asignarle un escudo protector.")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.xl)
                        }
                        .frame(maxHeight: .infinity)
                    } else if user.totalXp < GamificationEngine.shieldXPCost {
                        // Sin saldo suficiente
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "x.circle.fill")
                                .font(.title)
                                .foregroundStyle(Color.habDanger)
                            Text("Experiencia insuficiente")
                                .font(.headline)
                            Text("Necesitas al menos \(GamificationEngine.shieldXPCost) XP para comprar un escudo.")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.xl)
                        }
                        .frame(maxHeight: max(200, .infinity))
                    } else {
                        // Lista de hábitos
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                Text("¿A QUÉ HÁBITO QUIERES ASIGNAR EL ESCUDO?")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .padding(.horizontal, Spacing.lg)
                                    .padding(.top, Spacing.md)
                                    .padding(.bottom, Spacing.xs)
                                
                                ForEach(habits) { habit in
                                    Button {
                                        purchase(for: habit)
                                    } label: {
                                        HStack(spacing: Spacing.md) {
                                            ZStack {
                                                Circle()
                                                    .fill(habit.swiftUIColor.opacity(0.1))
                                                    .frame(width: 40, height: 40)
                                                Image(systemName: habit.icon ?? "star.fill")
                                                    .foregroundStyle(habit.swiftUIColor)
                                                    .font(.system(size: 16, weight: .semibold))
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
                                            
                                            Text("Comprar ⚡")
                                                .font(.caption.bold())
                                                .foregroundStyle(Color.habPrimary)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(Color.habPrimary.opacity(0.1))
                                                .cornerRadius(Radius.sm)
                                        }
                                        .padding(14)
                                        .background(Color.habCard)
                                        .cornerRadius(Radius.lg)
                                        .shadow(color: Color.black.opacity(0.01), radius: 4, x: 0, y: 2)
                                        .padding(.horizontal, Spacing.lg)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Comprar Escudo")
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
        }
    }
    
    private func purchase(for habit: Habit) {
        let success = GamificationEngine.purchaseShield(for: habit, user: user, context: modelContext)
        
        let generator = UINotificationFeedbackGenerator()
        if success {
            generator.notificationOccurred(.success)
            dismiss()
        } else {
            generator.notificationOccurred(.error)
        }
    }
}

#Preview {
    ShieldShopSheet(user: User(email: "", passwordHash: ""), habits: [])
}
