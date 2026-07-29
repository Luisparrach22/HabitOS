// ──────────────────────────────────────────────
// GamificationWidget.swift — Widget de Gamificación
// ──────────────────────────────────────────────
// Muestra la progresión del jugador: nivel, XP, escudos
// y racha máxima con anillo de progreso visual.

import WidgetKit
import SwiftUI

struct GamificationWidgetEntryView: View {
    var entry: HabitWidgetTimelineProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var xpProgress: Double {
        Double(entry.currentXP) / Double(max(1, entry.nextLevelXP))
    }
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }
    
    // MARK: - Vista Small: Anillo XP + Stats compactos
    private var smallView: some View {
        VStack(spacing: 8) {
            // Anillo de XP
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 7)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(1.0, xpProgress)))
                    .stroke(
                        AngularGradient(
                            colors: [Color(hex: "#7B2CBF"), Color(hex: "#00F5D4"), Color(hex: "#7B2CBF")],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#FFD700"))
                    
                    Text("\(entry.userLevel)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("NIVEL")
                        .font(.system(size: 7, weight: .black))
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 80, height: 80)
            
            // Stats compactos
            HStack(spacing: 10) {
                HStack(spacing: 3) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: "#00F5D4"))
                    Text("\(entry.activeShields)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 3) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: "#FF6B00"))
                    Text("\(entry.totalStreak)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(12)
        .background(Color(hex: "#0D0F14"))
    }
    
    // MARK: - Vista Medium: Anillo XP + Panel de estadísticas
    private var mediumView: some View {
        HStack(spacing: 16) {
            // Panel Izquierdo: Anillo XP grande
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 9)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(min(1.0, xpProgress)))
                        .stroke(
                            AngularGradient(
                                colors: [Color(hex: "#7B2CBF"), Color(hex: "#00F5D4"), Color(hex: "#7B2CBF")],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 9, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#FFD700"))
                        
                        Text("\(entry.userLevel)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("NIVEL")
                            .font(.system(size: 8, weight: .black))
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 90, height: 90)
                
                Text(entry.userName)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(width: 110)
            
            // Separador
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1)
            
            // Panel Derecho: Stats detallados
            VStack(alignment: .leading, spacing: 12) {
                // XP
                statRow(
                    icon: "bolt.fill",
                    iconColor: Color(hex: "#FFD700"),
                    label: "EXPERIENCIA",
                    value: "\(entry.currentXP)/\(entry.nextLevelXP) XP",
                    progress: xpProgress
                )
                
                // Escudos
                statRow(
                    icon: "shield.fill",
                    iconColor: Color(hex: "#00F5D4"),
                    label: "ESCUDOS",
                    value: "\(entry.activeShields) activos",
                    progress: nil
                )
                
                // Racha
                statRow(
                    icon: "flame.fill",
                    iconColor: Color(hex: "#FF6B00"),
                    label: "MEJOR RACHA",
                    value: "\(entry.maxStreak) días",
                    progress: nil
                )
            }
        }
        .padding(14)
        .background(Color(hex: "#0D0F14"))
    }
    
    // Componente reutilizable de fila de estadística
    private func statRow(icon: String, iconColor: Color, label: String, value: String, progress: Double?) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 9))
                    .foregroundColor(iconColor)
                Text(label)
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(.gray)
            }
            
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if let progress = progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 4)
                        Capsule()
                            .fill(LinearGradient(
                                colors: [Color(hex: "#7B2CBF"), Color(hex: "#00F5D4")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * CGFloat(progress), height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
    }
}

struct GamificationWidget: Widget {
    let kind: String = "GamificationWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetTimelineProvider()) { entry in
            GamificationWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("HabitOS — Gamificación")
        .description("Tu progresión de nivel, XP, escudos y racha máxima en un widget visual.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
