// ──────────────────────────────────────────────
// HabitCard.swift — Tarjeta de Hábito Interactiva
// ──────────────────────────────────────────────
// Componente que renderiza un hábito individual.
// Incluye un círculo interactivo para check-in con
// respuesta háptica y micro-animación de escala al pulsar.

import SwiftUI

struct HabitCard: View {
    let habit: Habit
    var onCheckin: () -> Void
    var onTapGesture: () -> Void
    
    // Estado local para la micro-animación de pulsación
    @State private var isPressing = false
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            
            // Icono del hábito con su color personalizado
            ZStack {
                Circle()
                    .fill(habit.swiftUIColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: habit.icon ?? "star.fill")
                    .foregroundStyle(habit.swiftUIColor)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            // Textos descriptivos (Nombre, disparador y racha)
            VStack(alignment: .leading, spacing: 3) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundStyle(habit.isCompletedToday ? Color.secondary : Color.primary)
                    .strikethrough(habit.isCompletedToday, color: Color.secondary.opacity(0.4))
                    .animation(.default, value: habit.isCompletedToday)
                
                // Mostrar disparador o frecuencia
                Text(habit.trigger ?? habit.frequency.displayName)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
                
                // Racha actual e indicativo de escudos
                HStack(spacing: 10) {
                    // Racha de fuego
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(habit.isCompletedToday ? Color.habWarning : Color.secondary)
                            .font(.caption)
                        Text("\(habit.currentStreak)d racha")
                            .font(.caption.bold())
                            .foregroundStyle(Color.secondary)
                    }
                    
                    // Escudos activos (si tiene)
                    if habit.shields > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "shield.fill")
                                .foregroundStyle(Color.habPrimary)
                                .font(.caption)
                            Text("\(habit.shields)")
                                .font(.caption.bold())
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
                .padding(.top, 2)
            }
            
            Spacer()
            
            // Botón de Check-in Interactivo
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                onCheckin()
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(
                            habit.isCompletedToday ? Color.habSuccess : habit.swiftUIColor,
                            lineWidth: 2
                        )
                        .background(
                            Circle()
                                .fill(habit.isCompletedToday ? Color.habSuccess : Color.clear)
                        )
                        .frame(width: 32, height: 32)
                    
                    if habit.isCompletedToday {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 12, weight: .bold))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: habit.isCompletedToday)
        }
        .padding(14)
        .background(Color.habCard)
        .cornerRadius(Radius.lg)
        .shadow(
            color: Color.black.opacity(0.02),
            radius: 6, x: 0, y: 3
        )
        .scaleEffect(isPressing ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressing)
        .onTapGesture {
            onTapGesture()
        }
        .onLongPressGesture(minimumDuration: 0.4, pressing: { pressing in
            self.isPressing = pressing
        }, perform: {
            onTapGesture()
        })
    }
}

// MARK: - Previsualización
#Preview {
    ZStack {
        Color.habBackground.ignoresSafeArea()
        VStack(spacing: Spacing.md) {
            HabitCard(
                habit: Habit(
                    userId: "1",
                    name: "Meditación matutina",
                    trigger: "Después del café",
                    frequency: .daily,
                    color: "#8B5CF6",
                    icon: "sparkles",
                    currentStreak: 5,
                    shields: 2
                ),
                onCheckin: {},
                onTapGesture: {}
            )
        }
        .padding()
    }
}
