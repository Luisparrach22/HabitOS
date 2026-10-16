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

            Image(systemName: habit.icon ?? "star.fill")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        colors: [habit.swiftUIColor.opacity(0.85), habit.swiftUIColor],
                        startPoint: .top, endPoint: .bottom
                    ),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .shadow(color: habit.swiftUIColor.opacity(0.35), radius: 8, y: 3)
                .saturation(habit.isCompletedToday ? 0.6 : 1)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(habit.name)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(habit.isCompletedToday ? Color.secondary : Color.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(habit.trigger ?? habit.frequency.displayName)
                        .lineLimit(1)
                    if habit.currentStreak > 0 {
                        Label("\(habit.currentStreak)", systemImage: "flame.fill")
                            .foregroundStyle(Color.habWarning)
                    }
                    if habit.shields > 0 {
                        Label("\(habit.shields)", systemImage: "shield.fill")
                            .foregroundStyle(Color.habPrimary)
                    }
                }
                .font(.footnote)
                .foregroundStyle(Color.secondary)
            }

            Spacer(minLength: Spacing.sm)

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onCheckin()
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(habit.swiftUIColor.opacity(0.55), lineWidth: 2)
                        .opacity(habit.isCompletedToday ? 0 : 1)
                    Circle()
                        .fill(habit.swiftUIColor)
                        .scaleEffect(habit.isCompletedToday ? 1 : 0.2)
                        .opacity(habit.isCompletedToday ? 1 : 0)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .opacity(habit.isCompletedToday ? 1 : 0)
                }
                .frame(width: 32, height: 32)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(habit.isCompletedToday ? "Marcar \(habit.name) como pendiente" : "Completar \(habit.name)")
            .animation(.bouncy(duration: 0.35), value: habit.isCompletedToday)
        }
        .padding(.leading, Spacing.md)
        .padding(.trailing, Spacing.xs)
        .padding(.vertical, Spacing.md)
        .glassCard(Radius.lg, tint: habit.isCompletedToday ? habit.swiftUIColor : nil, interactive: true)
        .contentShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .onTapGesture { onTapGesture() }
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
