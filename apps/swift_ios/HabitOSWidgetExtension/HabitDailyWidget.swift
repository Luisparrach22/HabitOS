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
        let completedCount = entry.habits.filter(\.isCompletedToday).count
        let totalCount = max(1, entry.habits.count)
        let progress = Double(completedCount) / Double(totalCount)

        return VStack(spacing: 8) {
            ZStack {
                WidgetRing(progress: progress, lineWidth: 9)
                VStack(spacing: 0) {
                    Text("\(completedCount)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Text("de \(entry.habits.count)")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 6) {
                Label("\(entry.totalStreak)", systemImage: "flame.fill")
                    .foregroundStyle(Color(hex: "#FF9F0A"))
                    .widgetChip()
                Label("\(entry.activeShields)", systemImage: "shield.fill")
                    .foregroundStyle(Color(hex: "#31D0F5"))
                    .widgetChip()
            }
            .font(.caption2.weight(.semibold))
        }
    }

    // MARK: - Vista Mediana (systemMedium) con botones interactivos
    private var mediumWidgetView: some View {
        let completedCount = entry.habits.filter(\.isCompletedToday).count
        let progress = Double(completedCount) / Double(max(1, entry.habits.count))

        return HStack(spacing: 14) {
            VStack(spacing: 6) {
                ZStack {
                    WidgetRing(progress: progress, lineWidth: 8)
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .frame(width: 76, height: 76)

                Label("\(entry.totalStreak)", systemImage: "flame.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color(hex: "#FF9F0A"))
                    .widgetChip()
            }
            .frame(width: 84)

            VStack(alignment: .leading, spacing: 6) {
                if entry.habits.isEmpty {
                    Text("Sin hábitos creados")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(entry.habits.prefix(4)) { habit in
                        Button(intent: ToggleHabitIntent(habitIDString: habit.id)) {
                            HStack(spacing: 8) {
                                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 17))
                                    .foregroundStyle(habit.isCompletedToday ? Color(hex: habit.colorHex) : Color.secondary)
                                Text(habit.title)
                                    .font(.system(.caption, design: .rounded, weight: .semibold))
                                    .foregroundStyle(habit.isCompletedToday ? .secondary : .primary)
                                    .strikethrough(habit.isCompletedToday)
                                    .lineLimit(1)
                                Spacer(minLength: 0)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct HabitDailyWidget: Widget {
    let kind: String = "HabitDailyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetTimelineProvider()) { entry in
            HabitDailyWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) { WidgetAurora() }
        }
        .configurationDisplayName("HabitOS — Diario")
        .description("Visualiza y completa tus hábitos diarios desde tu pantalla de inicio.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
