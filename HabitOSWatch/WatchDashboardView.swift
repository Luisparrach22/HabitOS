// ──────────────────────────────────────────────
// WatchDashboardView.swift — Vista Principal para watchOS
// ──────────────────────────────────────────────
// Interfaz táctil y minimalista adaptada al Apple Watch.
// Muestra el nivel del usuario y permite marcar y desmarcar hábitos.

import SwiftUI
import SwiftData

struct WatchDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Consultamos los datos de usuario y hábitos de SwiftData
    @Query(sort: \Habit.createdAt, order: .forward) private var habits: [Habit]
    @Query private var users: [User]
    
    // Instanciamos el ViewModel compartido para manejar lógica
    @State private var viewModel = HabitViewModel()
    @State private var hapticTrigger = false
    
    private var currentUser: User? {
        users.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    // ── Cabecera de Perfil ──
                    if let user = currentUser {
                        HStack(spacing: 6) {
                            AvatarView(avatarString: user.avatarUrl, size: 20)
                            
                            VStack(alignment: .leading) {
                                Text(user.name ?? "Héroe")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.primary)
                                
                                Text("Nivel \(user.level)")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            // XP
                            Text("\(user.totalXp) XP")
                                .font(.system(size: 10, weight: .semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.purple.opacity(0.2))
                                .cornerRadius(4)
                        }
                        .padding(.horizontal, 4)
                        .padding(.bottom, 4)
                    }
                    
                    Divider()
                    
                    // ── Lista de Hábitos ──
                    if habits.isEmpty {
                        VStack(spacing: 6) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                            Text("Sin hábitos hoy")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 16)
                    } else {
                        ForEach(habits) { habit in
                            Button {
                                let user = viewModel.ensureDefaultUser(context: modelContext)
                                viewModel.toggleCompletion(for: habit, user: user, context: modelContext)
                                hapticTrigger.toggle()
                            } label: {
                                HStack(spacing: 8) {
                                    // Estado completado (icono)
                                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 18))
                                        .foregroundStyle(habit.isCompletedToday ? Color(hex: habit.color ?? "#8B5CF6") : .secondary)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(habit.name)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(habit.isCompletedToday ? .secondary : .primary)
                                            .strikethrough(habit.isCompletedToday, color: .secondary)
                                            .lineLimit(1)
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "flame.fill")
                                                .font(.system(size: 8))
                                                .foregroundStyle(.orange)
                                            
                                            Text("\(habit.currentStreak) racha")
                                                .font(.system(size: 9))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Icono del hábito
                                    Image(systemName: habit.icon ?? "heart.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color(hex: habit.color ?? "#8B5CF6"))
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("HabitOS")
            // Efecto háptico premium al completar
            .sensoryFeedback(.impact(flexibility: .solid, intensity: 0.8), trigger: hapticTrigger)
        }
    }
}
