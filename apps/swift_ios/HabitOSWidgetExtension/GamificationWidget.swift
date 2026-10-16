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
    
    // MARK: - Vista Small
    private var smallView: some View {
        VStack(spacing: 8) {
            ZStack {
                WidgetRing(progress: xpProgress, lineWidth: 9)
                VStack(spacing: 0) {
                    Text("Nivel")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text("\(entry.userLevel)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 6) {
                Label("\(entry.activeShields)", systemImage: "shield.fill")
                    .foregroundStyle(Color(hex: "#31D0F5"))
                    .widgetChip()
                Label("\(entry.totalStreak)", systemImage: "flame.fill")
                    .foregroundStyle(Color(hex: "#FF9F0A"))
                    .widgetChip()
            }
            .font(.caption2.weight(.semibold))
        }
    }
    
    // MARK: - Vista Medium
    private var mediumView: some View {
        HStack(spacing: 18) {
            VStack(spacing: 6) {
                ZStack {
                    WidgetRing(progress: xpProgress, lineWidth: 10)
                    VStack(spacing: 0) {
                        Text("Nivel")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text("\(entry.userLevel)")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                    }
                }
                .frame(width: 92, height: 92)

                Text(entry.userName)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .lineLimit(1)
            }
            .frame(width: 100)

            VStack(alignment: .leading, spacing: 10) {
                statRow(icon: "bolt.fill", color: Color(hex: "#FFD60A"), label: "Experiencia", value: "\(entry.currentXP) / \(entry.nextLevelXP) XP")
                statRow(icon: "shield.fill", color: Color(hex: "#31D0F5"), label: "Escudos", value: "\(entry.activeShields) activos")
                statRow(icon: "flame.fill", color: Color(hex: "#FF9F0A"), label: "Mejor racha", value: "\(entry.maxStreak) días")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func statRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 24, height: 24)
                .glassEffect(.regular, in: Circle())
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
            }
        }
    }
}

struct GamificationWidget: Widget {
    let kind: String = "GamificationWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetTimelineProvider()) { entry in
            GamificationWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) { WidgetAurora() }
        }
        .configurationDisplayName("HabitOS — Gamificación")
        .description("Tu progresión de nivel, XP, escudos y racha máxima en un widget visual.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
