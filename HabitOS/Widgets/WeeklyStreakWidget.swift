// ──────────────────────────────────────────────
// WeeklyStreakWidget.swift — Widget de Racha Semanal
// ──────────────────────────────────────────────
// Muestra un mini-gráfico de barras con la actividad
// de los últimos 7 días directamente en la pantalla de inicio.

import WidgetKit
import SwiftUI

struct WeeklyStreakWidgetEntryView: View {
    var entry: HabitWidgetTimelineProvider.Entry
    
    var body: some View {
        weeklyMediumView
    }
    
    // MARK: - Vista Medium: Gráfico de Barras Semanal
    private var weeklyMediumView: some View {
        let activeDays = entry.weeklyActivity.filter { $0.completedCount > 0 }.count
        
        return HStack(spacing: 14) {
            // Panel Izquierdo: Stats resumen
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ESTA SEMANA")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.gray)
                    
                    Text("\(activeDays)/7")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("días activos")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#FF6B00"))
                        Text("Racha: \(entry.totalStreak)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#FFD700"))
                        Text("Mejor: \(entry.maxStreak)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 95)
            
            // Separador vertical sutil
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1)
            
            // Panel Derecho: Gráfico de barras de 7 días
            VStack(spacing: 0) {
                // Barras
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(entry.weeklyActivity) { day in
                        VStack(spacing: 4) {
                            // Porcentaje encima de la barra del día actual
                            if day.isToday && day.totalCount > 0 {
                                Text("\(Int(day.percentage * 100))%")
                                    .font(.system(size: 7, weight: .black))
                                    .foregroundColor(Color(hex: "#00F5D4"))
                            } else {
                                Text(" ")
                                    .font(.system(size: 7))
                            }
                            
                            // Barra
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    day.isToday
                                    ? LinearGradient(colors: [Color(hex: "#7B2CBF"), Color(hex: "#00F5D4")], startPoint: .bottom, endPoint: .top)
                                    : LinearGradient(colors: [Color(hex: "#7B2CBF").opacity(day.percentage > 0 ? 0.7 : 0.15), Color(hex: "#7B2CBF").opacity(day.percentage > 0 ? 0.9 : 0.15)], startPoint: .bottom, endPoint: .top)
                                )
                                .frame(height: max(4, CGFloat(day.percentage) * 50))
                            
                            // Etiqueta del día
                            Text(day.dayLabel)
                                .font(.system(size: 8, weight: day.isToday ? .black : .medium))
                                .foregroundColor(day.isToday ? Color(hex: "#00F5D4") : .gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .padding(14)
        .background(Color(hex: "#0D0F14"))
    }
}

struct WeeklyStreakWidget: Widget {
    let kind: String = "WeeklyStreakWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetTimelineProvider()) { entry in
            WeeklyStreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("HabitOS — Semana")
        .description("Visualiza tu actividad de los últimos 7 días con un gráfico de barras.")
        .supportedFamilies([.systemMedium])
    }
}
