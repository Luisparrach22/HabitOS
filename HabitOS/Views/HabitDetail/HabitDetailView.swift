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
                                .fill(habit.swiftUIColor.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: habit.icon ?? "star.fill")
                                .foregroundStyle(habit.swiftUIColor)
                                .font(.system(size: 36, weight: .bold))
                        }
                        .padding(.top, Spacing.lg)
                        
                        Text(habit.name)
                            .font(.habTitle1)
                            .foregroundStyle(Color.habTextPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.lg)
                        
                        if let desc = habit.habitDescription {
                            Text(desc)
                                .font(.habBody)
                                .foregroundStyle(Color.habTextMuted)
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
                                    .font(.title)
                                    .foregroundStyle(Color.habWarning)
                                
                                Text("\(habit.currentStreak) días")
                                    .font(.habHeadline)
                                    .foregroundStyle(Color.habTextPrimary)
                                
                                Text("Racha Actual")
                                    .font(.habCaption)
                                    .foregroundStyle(Color.habTextMuted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.lg)
                            .background(Color.habCard)
                            .cornerRadius(Radius.lg)
                            
                            // Tarjeta: Racha Máxima
                            VStack(spacing: Spacing.xs) {
                                Image(systemName: "trophy.fill")
                                    .font(.title)
                                    .foregroundStyle(Color(hex: "#F5A623"))
                                
                                Text("\(habit.maxStreak) días")
                                    .font(.habHeadline)
                                    .foregroundStyle(Color.habTextPrimary)
                                
                                Text("Racha Máxima")
                                    .font(.habCaption)
                                    .foregroundStyle(Color.habTextMuted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.lg)
                            .background(Color.habCard)
                            .cornerRadius(Radius.lg)
                        }
                        
                        // Tarjeta: Escudos Protectores
                        HStack(spacing: Spacing.lg) {
                            Image(systemName: "shield.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Color.habPrimary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(habit.shields) Escudos")
                                    .font(.habHeadline)
                                    .foregroundStyle(Color.habTextPrimary)
                                
                                Text("Protegen tu racha si fallas un día")
                                    .font(.habFootnote)
                                    .foregroundStyle(Color.habTextMuted)
                            }
                            
                            Spacer()
                            
                            // Botón para añadir escudo (para propósitos de prueba / gamificación)
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                
                                withAnimation {
                                    habit.shields += 1
                                    try? modelContext.save()
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.habPrimary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(Spacing.lg)
                        .background(Color.habCard)
                        .cornerRadius(Radius.lg)
                    }
                    .padding(.horizontal, Spacing.lg)
                    
                    // 3. Información del Disparador (Habit Stack)
                    if let trig = habit.trigger {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("DISPARADOR ASOCIADO")
                                .font(.habCaption)
                                .foregroundStyle(Color.habTextMuted)
                                .padding(.horizontal, Spacing.xs)
                            
                            HStack {
                                Image(systemName: "link")
                                    .foregroundStyle(habit.swiftUIColor)
                                Text(trig)
                                    .font(.habBody)
                                    .foregroundStyle(Color.habTextPrimary)
                                Spacer()
                            }
                            .padding(Spacing.md)
                            .background(Color.habCardMuted)
                            .cornerRadius(Radius.md)
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                    
                    Spacer()
                    
                    // 4. Botón de Eliminar Hábito
                    Button {
                        deleteHabit()
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Eliminar Hábito")
                                .fontWeight(.bold)
                        }
                        .font(.habBody)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(Color.habDanger)
                        .cornerRadius(Radius.md)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .font(.habHeadline)
                    .foregroundStyle(Color.habPrimary)
                }
            }
        }
    }
    
    // Función para borrar el hábito
    private func deleteHabit() {
        // Ejecutar feedback táctil de advertencia
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        // Eliminamos el objeto del contexto de SwiftData
        modelContext.delete(habit)
        
        do {
            try modelContext.save()
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
