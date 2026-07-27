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

    // MARK: - Pantalla de Bloqueo: Circular
    private var circularLockScreenView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: "flame.fill")
                    .font(.caption)
                Text("\(entry.totalStreak)")
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }

    // MARK: - Pantalla de Bloqueo: Rectangular
    private var rectangularLockScreenView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "flame.fill")
                Text("HabitOS • Nivel \(entry.userLevel)")
                    .font(.caption2.bold())
            }
            Text("Racha: \(entry.totalStreak) días")
                .font(.headline)
            Text("\(entry.activeShields) Escudos Activos")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Pantalla de Bloqueo: En línea (Inline)
    private var inlineLockScreenView: some View {
        Label("\(entry.totalStreak) días de racha • Nivel \(entry.userLevel)", systemImage: "flame.fill")
    }

    // MARK: - Vista Pequeña para Inicio
    private var streakSmallHomeWidgetView: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: CGFloat(min(1.0, Double(entry.currentXP) / Double(max(1, entry.nextLevelXP)))))
                    .stroke(
                        AngularGradient(colors: [Color(hex: "#FF6B00"), Color(hex: "#00F5D4")], center: .center),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#FF6B00"))
                    Text("\(entry.totalStreak)")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.white)
                    Text("DÍAS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 90, height: 90)

            HStack(spacing: 6) {
                Text("Niv. \(entry.userLevel)")
                    .font(.caption2.bold())
                    .foregroundColor(Color(hex: "#7B2CBF"))
                Text("•")
                    .foregroundColor(.gray)
                Label("\(entry.activeShields)", systemImage: "shield.fill")
                    .font(.caption2.bold())
                    .foregroundColor(Color(hex: "#00F5D4"))
            }
        }
        .padding(12)
        .background(Color(hex: "#0D0F14"))
    }
}

struct HabitStreakWidget: Widget {
    let kind: String = "HabitStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetTimelineProvider()) { entry in
            HabitStreakWidgetEntryView(entry: entry)
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
