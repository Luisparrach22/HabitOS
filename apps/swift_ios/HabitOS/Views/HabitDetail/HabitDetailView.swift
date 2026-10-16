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
    
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                // Cabecera
                Section {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: habit.icon ?? "star.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(habit.swiftUIColor, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .accessibilityHidden(true)

                        Text(habit.name)
                            .font(.title2.weight(.semibold))
                            .multilineTextAlignment(.center)

                        if let desc = habit.habitDescription, !desc.isEmpty {
                            Text(desc)
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .listRowBackground(Color.clear)
                }

                // Rachas
                Section("Rachas") {
                    LabeledContent {
                        Text("\(habit.currentStreak) días").monospacedDigit()
                    } label: {
                        Label("Actual", systemImage: "flame.fill")
                            .foregroundStyle(Color.primary)
                    }
                    LabeledContent {
                        Text("\(habit.maxStreak) días").monospacedDigit()
                    } label: {
                        Label("Máxima", systemImage: "trophy.fill")
                            .foregroundStyle(Color.primary)
                    }
                }
                .glassListRow()

                // Escudos
                Section {
                    LabeledContent {
                        Text("\(habit.shields)").monospacedDigit()
                    } label: {
                        Label("Escudos", systemImage: "shield.fill")
                            .foregroundStyle(Color.primary)
                    }
                    if let user = currentUser {
                        let canAfford = user.totalXp >= GamificationEngine.shieldXPCost
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            showingPurchaseConfirmation = true
                        } label: {
                            LabeledContent("Comprar escudo", value: "\(GamificationEngine.shieldXPCost) XP")
                        }
                        .disabled(!canAfford)
                    }
                } footer: {
                    Text("Protegen tu racha si fallas un día.")
                }
                .glassListRow()

                if let trig = habit.trigger, !trig.isEmpty {
                    Section("Disparador") {
                        Label(trig, systemImage: "link")
                            .foregroundStyle(Color.primary)
                    }
                }

                Section {
                    Button {
                        showingFocusTimer = true
                    } label: {
                        Label("Modo enfoque", systemImage: "timer")
                    }
                }
                .glassListRow()

                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Text("Eliminar hábito")
                            .frame(maxWidth: .infinity)
                    }
                }
                .glassListRow()
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background { AuroraBackground() }
            .tint(Color.habPrimary)
            .confirmationDialog("¿Eliminar este hábito?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Eliminar hábito", role: .destructive) { deleteHabit() }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Se perderá su historial y su racha.")
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
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Comprar escudo", isPresented: $showingPurchaseConfirmation) {
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
