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
        VStack(alignment: .leading, spacing: Spacing.md) {
            
            // Fila de Cabecera: Progreso de Hábitos e Icono de Racha
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("PROGRESO HOY")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.habTextSecondary)
                    
                    if totalCount > 0 {
                        Text("\(completedCount) de \(totalCount) completados")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.habTextPrimary)
                    } else {
                        Text("Comienza tu rutina")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.habTextPrimary)
                    }
                }
                
                Spacer()
                
                // Medallón de racha actual con estilo HIG premium
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#FF9F0A"), Color(hex: "#FF3B30")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("\(maxCurrentStreak)")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.habTextPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.habCardMuted)
                .cornerRadius(Radius.md)
            }
            
            // Barra de progreso delgada de 8pt con gradiente premium
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fondo de la barra
                    Capsule()
                        .fill(Color.primary.opacity(0.06))
                        .frame(height: 8)
                    
                    // Barra de progreso con gradiente
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#7B2CBF"), Color(hex: "#00F5D4")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: progress)
                }
            }
            .frame(height: 8)
            
            // Mensaje motivacional según progreso
            Text(motivationalMessage)
                .font(.footnote)
                .foregroundStyle(Color.habTextMuted)
        }
        .padding(18)
        .background(Color.habCard)
        .cornerRadius(Radius.xl2)
        .shadow(
            color: Color.black.opacity(0.02),
            radius: 8, x: 0, y: 4
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
