// ──────────────────────────────────────────────
// HabitDailyWidget.swift — Widget Diario de Hábitos (Small & Medium)
// ──────────────────────────────────────────────
// Muestra los hábitos pendientes del día con botones interactivos (iOS 17+)
// que permiten completarlos o desmarcarlos directamente en la pantalla de inicio.

import WidgetKit
import SwiftUI
import AppIntents

struct HabitDailyWidgetEntryView: View {
    var entry: HabitWidgetTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        case .systemMedium:
            mediumWidgetView
        default:
            mediumWidgetView
        }
    }

    // MARK: - Vista Pequeña (systemSmall)
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(Color(hex: "#FF6B00"))
                Text("\(entry.totalStreak) días")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "shield.fill")
                    .foregroundColor(Color(hex: "#00F5D4"))
                    .font(.caption2)
                Text("\(entry.activeShields)")
                    .font(.caption2.bold())
                    .foregroundColor(.white)
            }
            
            Spacer()

            let completedCount = entry.habits.filter(\.isCompletedToday).count
            let totalCount = max(1, entry.habits.count)
            let progress = Double(completedCount) / Double(totalCount)

            VStack(alignment: .leading, spacing: 4) {
                Text("PROGRESO HOY")
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.gray)

                Text("\(completedCount)/\(totalCount) Hábitos")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 6)
                        Capsule()
                            .fill(LinearGradient(colors: [Color(hex: "#7B2CBF"), Color(hex: "#00F5D4")], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(14)
        .background(Color(hex: "#0D0F14"))
    }

    // MARK: - Vista Mediana (systemMedium) con Botones Interactivos (AppIntent)
    private var mediumWidgetView: some View {
        HStack(spacing: 16) {
            // Panel Izquierdo: Nivel y Resumen
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("NIVEL")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(Color(hex: "#7B2CBF"))
                    Text("\(entry.userLevel)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }

                Text(entry.userName)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                HStack(spacing: 8) {
                    Label("\(entry.totalStreak)", systemImage: "flame.fill")
                        .font(.caption.bold())
                        .foregroundColor(Color(hex: "#FF6B00"))

                    Label("\(entry.activeShields)", systemImage: "shield.fill")
                        .font(.caption.bold())
                        .foregroundColor(Color(hex: "#00F5D4"))
                }
            }
            .frame(width: 110)

            Divider()
                .background(Color.white.opacity(0.15))

            // Panel Derecho: Lista de Hábitos Interactivos
            VStack(alignment: .leading, spacing: 6) {
                if entry.habits.isEmpty {
                    Text("Sin hábitos creados")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    ForEach(entry.habits) { habit in
                        HStack {
                            Button(intent: ToggleHabitIntent(habitIDString: habit.id)) {
                                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 18))
                                    .foregroundColor(habit.isCompletedToday ? Color(hex: "#00F5D4") : .gray)
                            }
                            .buttonStyle(.plain)

                            Text(habit.title)
                                .font(.caption.bold())
                                .foregroundColor(habit.isCompletedToday ? .gray : .white)
                                .strikethrough(habit.isCompletedToday)
                                .lineLimit(1)

                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color(hex: "#0D0F14"))
    }
}

struct HabitDailyWidget: Widget {
    let kind: String = "HabitDailyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetTimelineProvider()) { entry in
            HabitDailyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("HabitOS — Diario")
        .description("Visualiza y completa tus hábitos diarios desde tu pantalla de inicio.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
