// ──────────────────────────────────────────────
// HabitStreakWidget.swift — Widget de Racha y Pantalla de Bloqueo
// ──────────────────────────────────────────────
// Muestra la racha de días, el nivel y los escudos activos del usuario
// en la pantalla de bloqueo (Lock Screen Accessories) y pantalla de inicio.

import WidgetKit
import SwiftUI

struct HabitStreakWidgetEntryView: View {
    var entry: HabitWidgetTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryCircular:
            circularLockScreenView
        case .accessoryRectangular:
            rectangularLockScreenView
        case .accessoryInline:
            inlineLockScreenView
        default:
            streakSmallHomeWidgetView
        }
    }

    // MARK: - Pantalla de Bloqueo: Circular (Progreso Diario)
    private var circularLockScreenView: some View {
        let completedCount = entry.habits.filter(\.isCompletedToday).count
        let totalCount = entry.habits.count
        
        return ZStack {
            AccessoryWidgetBackground()
            
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 3.5)
            
            Circle()
                .trim(from: 0, to: CGFloat(min(1.0, Double(completedCount) / Double(max(1, totalCount)))))
                .stroke(Color.white, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 0) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 9))
                Text("\(completedCount)/\(totalCount)")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
            }
        }
    }

    // MARK: - Pantalla de Bloqueo: Rectangular (Lista de Pendientes)
    private var rectangularLockScreenView: some View {
        let pending = entry.habits.filter { !$0.isCompletedToday }
        
        return VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "checklist")
                    .font(.caption2)
                Text("Pendientes")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            if pending.isEmpty {
                Text("Todo al día")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.top, 1)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(pending.prefix(2))) { habit in
                        HStack(spacing: 4) {
                            Image(systemName: "circle")
                                .font(.system(size: 7))
                            Text(habit.title)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Pantalla de Bloqueo: En línea (Inline)
    private var inlineLockScreenView: some View {
        let pendingCount = entry.habits.filter { !$0.isCompletedToday }.count
        return Label("Racha \(entry.totalStreak) · Pendientes \(pendingCount)", systemImage: "flame.fill")
    }

    // MARK: - Vista Pequeña para Inicio
    private var streakSmallHomeWidgetView: some View {
        let progress = Double(entry.currentXP) / Double(max(1, entry.nextLevelXP))
        return VStack(spacing: 8) {
            ZStack {
                WidgetRing(progress: progress, lineWidth: 8)
                VStack(spacing: 0) {
                    Image(systemName: "flame.fill")
                        .font(.body)
                        .foregroundStyle(Color(hex: "#FF9F0A"))
                    Text("\(entry.totalStreak)")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    Text("días")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 6) {
                Text("Nivel \(entry.userLevel)").widgetChip()
                Label("\(entry.activeShields)", systemImage: "shield.fill")
                    .foregroundStyle(Color(hex: "#31D0F5"))
                    .widgetChip()
            }
            .font(.caption2.weight(.semibold))
        }
    }
}

struct HabitStreakWidget: Widget {
    let kind: String = "HabitStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetTimelineProvider()) { entry in
            HabitStreakWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) { WidgetAurora() }
        }
        .configurationDisplayName("HabitOS — Racha y Nivel")
        .description("Sigue tu racha diaria y tus escudos activos desde tu pantalla de bloqueo o inicio.")
        .supportedFamilies([
            .systemSmall,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
