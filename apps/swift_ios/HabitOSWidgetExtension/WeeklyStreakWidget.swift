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
    
    // MARK: - Vista Medium: barras semanales
    private var weeklyMediumView: some View {
        let activeDays = entry.weeklyActivity.filter { $0.completedCount > 0 }.count

        return HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Esta semana")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Text("\(activeDays)/7")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text("días activos")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 4)

                Label("\(entry.totalStreak)", systemImage: "flame.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color(hex: "#FF9F0A"))
                    .widgetChip()
            }
            .frame(width: 92, alignment: .leading)

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(entry.weeklyActivity) { day in
                    VStack(spacing: 5) {
                        Capsule()
                            .fill(
                                day.isToday
                                ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "#31D0F5"), Color(hex: "#A855F7")], startPoint: .bottom, endPoint: .top))
                                : AnyShapeStyle(Color.primary.opacity(day.percentage > 0 ? 0.35 : 0.10))
                            )
                            .frame(height: max(8, CGFloat(day.percentage) * 64))
                        Text(day.dayLabel)
                            .font(.system(size: 10, weight: day.isToday ? .bold : .medium, design: .rounded))
                            .foregroundStyle(day.isToday ? Color.primary : Color.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

struct WeeklyStreakWidget: Widget {
    let kind: String = "WeeklyStreakWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetTimelineProvider()) { entry in
            WeeklyStreakWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) { WidgetAurora() }
        }
        .configurationDisplayName("HabitOS — Semana")
        .description("Visualiza tu actividad de los últimos 7 días con un gráfico de barras.")
        .supportedFamilies([.systemMedium])
    }
}
