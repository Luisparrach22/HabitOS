// ──────────────────────────────────────────────
// ProgressBar.swift — Tarjeta de Progreso Diario
// ──────────────────────────────────────────────
// Componente premium que muestra el progreso del día
// y la racha de hábitos actual más alta del usuario.

import SwiftUI

struct ProgressBar: View {
    let completedCount: Int
    let totalCount: Int
    let maxCurrentStreak: Int
    
    // Cálculo del porcentaje (evita división por cero)
    private var progress: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var body: some View {
        HStack(spacing: Spacing.xl2) {
            ZStack {
                ProgressRing(progress: progress, lineWidth: 13)
                VStack(spacing: 0) {
                    Text("\(Int(progress * 100))")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                    Text("%")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(width: 110, height: 110)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Progreso de hoy")
            .accessibilityValue("\(Int(progress * 100)) por ciento")

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(totalCount > 0 ? "\(completedCount) de \(totalCount) hoy" : "Sin hábitos aún")
                    .font(.system(.title3, design: .rounded, weight: .semibold))

                Text(motivationalMessage)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Label("\(maxCurrentStreak) días", systemImage: "flame.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(maxCurrentStreak > 0 ? Color.habWarning : Color.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .glassEffect(.regular, in: Capsule())
                    .accessibilityLabel("Racha de \(maxCurrentStreak) días")
            }
            Spacer(minLength: 0)
        }
        .padding(Spacing.xl2)
        .glassCard(Radius.xl)
    }

    // Genera un mensaje motivacional dinámico
    private var motivationalMessage: String {
        guard totalCount > 0 else { return "Añade un hábito para empezar." }
        let pct = progress
        if pct == 0 { return "Empieza con un pequeño paso." }
        if pct < 0.5 { return "Buen comienzo." }
        if pct < 1.0 { return "Casi lo tienes." }
        return "Día completo."
    }
}

// MARK: - Previsualización
#Preview {
    ZStack {
        Color.habBackground.ignoresSafeArea()
        ProgressBar(completedCount: 3, totalCount: 5, maxCurrentStreak: 12)
            .padding()
    }
}
