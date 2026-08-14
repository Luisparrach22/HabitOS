// ──────────────────────────────────────────────
// HabitDetailView.swift — Detalle del Hábito
// ──────────────────────────────────────────────
// Pantalla modal que se abre para mostrar información
// completa de un hábito, sus estadísticas (rachas y escudos)
// y permite eliminar el hábito de la base de datos SwiftData.

import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let habit: Habit
    
    @Query private var users: [User]
    @State private var showingPurchaseConfirmation = false
    @State private var showingFocusTimer = false
    @State private var showingEditSheet = false
    
    private var currentUser: User? {
        users.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.habBackground
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    
                    // 1. Cabecera Visual (Icono y nombre del Hábito)
                    VStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(habit.swiftUIColor.opacity(0.12))
                                .frame(width: 84, height: 84)
                            
                            Image(systemName: habit.icon ?? "star.fill")
                                .foregroundStyle(habit.swiftUIColor)
                                .font(.system(size: 36, weight: .semibold))
                        }
                        .padding(.top, Spacing.lg)
                        
                        Text(habit.name)
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.lg)
                        
                        if let desc = habit.habitDescription {
                            Text(desc)
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.xl)
                        }
                    }
                    
                    // 2. Módulos de Estadísticas (Rachas y Escudos)
                    VStack(spacing: Spacing.md) {
                        
                        // Fila de Rachas
                        HStack(spacing: Spacing.md) {
                            // Tarjeta: Racha Actual
                            VStack(spacing: Spacing.xs) {
                                Image(systemName: "flame.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.habWarning)
                                
                                Text("\(habit.currentStreak)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.primary)
                                
                                Text("Racha Actual")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.lg)
                            .background(Color.habCard)
                            .cornerRadius(Radius.lg)
                            .shadow(color: Color.black.opacity(0.01), radius: 4, x: 0, y: 2)
                            
                            // Tarjeta: Racha Máxima
                            VStack(spacing: Spacing.xs) {
                                Image(systemName: "trophy.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.habWarning)
                                
                                Text("\(habit.maxStreak)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.primary)
                                
                                Text("Racha Máxima")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.lg)
                            .background(Color.habCard)
                            .cornerRadius(Radius.lg)
                            .shadow(color: Color.black.opacity(0.01), radius: 4, x: 0, y: 2)
                        }
                        
                        // Tarjeta: Escudos Protectores
                        HStack(spacing: Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(Color.habPrimary.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "shield.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.habPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(habit.shields) Escudos disponibles")
                                    .font(.headline)
                                    .foregroundStyle(Color.primary)
                                
                                Text("Protegen tu racha si fallas un día")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            Spacer()
                            
                            // Botón para comprar escudo
                            if let user = currentUser {
                                let canAfford = user.totalXp >= GamificationEngine.shieldXPCost
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    showingPurchaseConfirmation = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                        Text("\(GamificationEngine.shieldXPCost) XP")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                    }
                                    .foregroundStyle(canAfford ? Color.habPrimary : Color.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(canAfford ? Color.habPrimary.opacity(0.1) : Color.primary.opacity(0.04))
                                    .cornerRadius(Radius.sm)
                                }
                                .buttonStyle(.plain)
                                .disabled(!canAfford)
                            }
                        }
                        .padding(14)
                        .background(Color.habCard)
                        .cornerRadius(Radius.lg)
                        .shadow(color: Color.black.opacity(0.01), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, Spacing.lg)
                    
                    // 3. Información del Disparador (Habit Stack)
                    if let trig = habit.trigger {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("DISPARADOR ASOCIADO")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .padding(.horizontal, Spacing.xs)
                            
                            HStack {
                                Image(systemName: "link")
                                    .foregroundStyle(habit.swiftUIColor)
                                    .font(.subheadline)
                                Text(trig)
                                    .font(.body)
                                    .foregroundStyle(Color.primary)
                                Spacer()
                            }
                            .padding(Spacing.md)
                            .background(Color.habCard)
                            .cornerRadius(Radius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.md)
                                    .stroke(Color.primary.opacity(0.04), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                    
                    // 4. Botón Iniciar Modo Enfoque
                    Button {
                        showingFocusTimer = true
                    } label: {
                        HStack {
                            Image(systemName: "timer")
                            Text("Iniciar Modo Enfoque")
                                .fontWeight(.bold)
                        }
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [habit.swiftUIColor, Color(hex: "#00F5D4")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(Radius.xl)
                        .shadow(color: habit.swiftUIColor.opacity(0.3), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Spacing.lg)
                    
                    // 5. Botón de Eliminar Hábito
                    Button {
                        deleteHabit()
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Eliminar Hábito")
                                .fontWeight(.bold)
                        }
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.habDanger)
                        .cornerRadius(Radius.xl)
                        .shadow(color: Color.habDanger.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
            }
            .sheet(isPresented: $showingFocusTimer) {
                FocusTimerSheet(habit: habit, isPro: currentUser?.isPro ?? false)
            }
            .sheet(isPresented: $showingEditSheet) {
                CreateHabitView(habitToEdit: habit)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Editar") {
                        showingEditSheet = true
                    }
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.habPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.habPrimary)
                }
            }
            .alert("Comprar Escudo 🛡️", isPresented: $showingPurchaseConfirmation) {
                Button("Cancelar", role: .cancel) {}
                Button("Comprar", role: .none) {
                    if let user = currentUser {
                        let success = GamificationEngine.purchaseShield(for: habit, user: user, context: modelContext)
                        let generator = UINotificationFeedbackGenerator()
                        if success {
                            generator.notificationOccurred(.success)
                        } else {
                            generator.notificationOccurred(.error)
                        }
                    }
                }
            } message: {
                Text("Se descontarán \(GamificationEngine.shieldXPCost) XP de tu cuenta para añadir 1 escudo a este hábito.")
            }
        }
    }
    
    // Función para borrar el hábito
    private func deleteHabit() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        let habitId = habit.id
        modelContext.delete(habit)
        
        do {
            try modelContext.save()
            Task {
                try? await SupabaseService.shared.deleteHabit(id: habitId)
            }
            dismiss()
        } catch {
            print("Error al borrar hábito: \(error)")
        }
    }
}

// MARK: - Previsualización
#Preview {
    HabitDetailView(
        habit: Habit(
            userId: "temp",
            name: "Beber Agua",
            habitDescription: "Salud general e hidratación",
            trigger: "Al entrar a la oficina",
            frequency: .daily,
            color: "#018ABE",
            icon: "drop.fill",
            currentStreak: 4,
            maxStreak: 12,
            shields: 1
        )
    )
}
