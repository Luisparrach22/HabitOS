// ──────────────────────────────────────────────
// ProgressBar.swift — Tarjeta de Progreso Diario
// ──────────────────────────────────────────────
// Componente premium que muestra el progreso del día
// y la racha de hábitos actual más alta del usuario.
// Incorpora un diseño Soft-UI, gradiente de progreso
// y esquinas redondeadas de 24pt.

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
        VStack(alignment: .leading, spacing: Spacing.md) {
            
            // Fila de Cabecera: Progreso de Hábitos e Icono de Racha
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Progreso de Hoy")
                        .font(.habHeadline)
                        .foregroundStyle(Color.habTextSecondary)
                    
                    if totalCount > 0 {
                        Text("\(completedCount) de \(totalCount) hábitos")
                            .font(.habLargeTitle)
                            .foregroundStyle(Color.habTextPrimary)
                    } else {
                        Text("Sin hábitos")
                            .font(.habLargeTitle)
                            .foregroundStyle(Color.habTextPrimary)
                    }
                }
                
                Spacer()
                
                // Medallón de racha actual
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color.habWarning)
                        .font(.title3)
                    
                    Text("\(maxCurrentStreak)")
                        .font(.habTitle3)
                        .foregroundStyle(Color.habTextPrimary)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color.habCardMuted)
                .cornerRadius(Radius.md)
            }
            
            // Barra de progreso propiamente
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fondo de la barra
                    Capsule()
                        .fill(Color.habBlueLight.opacity(0.3))
                        .frame(height: 12)
                    
                    // Barra de progreso con gradiente
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.habPrimary, .habBlueLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        // Anima el cambio de longitud
                        .frame(width: geometry.size.width * CGFloat(progress), height: 12)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)
                }
            }
            .frame(height: 12)
            
            // Mensaje motivacional según progreso
            Text(motivationalMessage)
                .font(.habFootnote)
                .foregroundStyle(Color.habTextMuted)
                .padding(.top, 4)
        }
        .padding(Spacing.xl)
        .background(Color.habCard)
        .cornerRadius(Radius.xl2) // 24pt corners de tu design system
        .shadow(
            color: Color.habTextDark.opacity(0.05),
            radius: 12, x: 0, y: 4
        )
    }
    
    // Genera un mensaje motivacional dinámico
    private var motivationalMessage: String {
        guard totalCount > 0 else { return "¡Añade un hábito para empezar tu rutina!" }
        let pct = progress
        if pct == 0 { return "Comienza con un pequeño paso hoy. ¡Tú puedes!" }
        if pct < 0.5 { return "¡Buen comienzo! Sigue adelante." }
        if pct < 1.0 { return "¡Estás muy cerca de completar tu día!" }
        return "¡Día perfecto! Has completado todos tus hábitos 🎉"
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
