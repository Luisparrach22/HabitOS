// ──────────────────────────────────────────────
// HabitCard.swift — Tarjeta de Hábito Interactiva
// ──────────────────────────────────────────────
// Componente que renderiza un hábito individual.
// Incluye un círculo interactivo para check-in con
// respuesta háptica y micro-animación de escala al pulsar.
//
// Diferencias con React Native:
// - Usa SwiftUI `@State` local para animar la pulsación.
// - Reacciona al toque con una animación de escala en toda la tarjeta.
// - Usa SF Symbols para los iconos.

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
                    .fill(habit.swiftUIColor.opacity(0.15))
                    .frame(width: 46, height: 46)
                
                Image(systemName: habit.icon ?? "star.fill")
                    .foregroundStyle(habit.swiftUIColor)
                    .font(.system(size: 20, weight: .semibold))
            }
            
            // Textos descriptivos (Nombre, disparador y racha)
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.habHeadline)
                    .foregroundStyle(Color.habTextPrimary)
                    .strikethrough(habit.isCompletedToday, color: Color.habTextMuted.opacity(0.5))
                    .animation(.default, value: habit.isCompletedToday)
                
                // Mostrar disparador o frecuencia
                Text(habit.trigger ?? habit.frequency.displayName)
                    .font(.habFootnote)
                    .foregroundStyle(Color.habTextMuted)
                    .lineLimit(1)
                
                // Racha actual e indicativo de escudos
                HStack(spacing: Spacing.md) {
                    // Racha de fuego
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(habit.isCompletedToday ? Color.habWarning : Color.habTextMuted)
                        Text("\(habit.currentStreak) d")
                            .font(.habCaption)
                            .foregroundStyle(Color.habTextSecondary)
                    }
                    
                    // Escudos activos (si tiene)
                    if habit.shields > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "shield.fill")
                                .foregroundStyle(Color.habPrimary)
                            Text("\(habit.shields)")
                                .font(.habCaption)
                                .foregroundStyle(Color.habTextSecondary)
                        }
                    }
                }
                .padding(.top, 2)
            }
            
            Spacer()
            
            // Botón de Check-in Interactivo
            Button {
                // Ejecutar feedback táctil ligero en iOS
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
                        .frame(width: 36, height: 36)
                    
                    if habit.isCompletedToday {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 14, weight: .bold))
                            // Animación de aparición
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .buttonStyle(.plain) // Evita que todo el HStack sea pulsable por el botón
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: habit.isCompletedToday)
        }
        .padding(Spacing.md)
        .background(Color.habCard)
        .cornerRadius(Radius.lg)
        .shadow(
            color: Color.habTextDark.opacity(0.04),
            radius: 8, x: 0, y: 2
        )
        // Animación de escala cuando el usuario mantiene presionado o pulsa
        .scaleEffect(isPressing ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressing)
        // Soporta gestos dobles o normales en la tarjeta
        .onTapGesture {
            onTapGesture()
        }
        // Simular efecto de pulsación física
        .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
            self.isPressing = pressing
        }, perform: {
            // Acción al mantener presionado (por ejemplo, ver detalles)
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
            
            HabitCard(
                habit: Habit(
                    userId: "1",
                    name: "Beber 2 litros de agua",
                    trigger: "Al entrar a la oficina",
                    frequency: .daily,
                    color: "#018ABE",
                    icon: "drop.fill",
                    currentStreak: 12,
                    shields: 0
                ),
                onCheckin: {},
                onTapGesture: {}
            )
        }
        .padding()
    }
}
