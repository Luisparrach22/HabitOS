// ──────────────────────────────────────────────
// HabitQuickAddWidget.swift — Widget de Acceso Rápido (Nuevo Hábito)
// ──────────────────────────────────────────────
// Acceso directo táctil que permite abrir la app en la pantalla
// de creación de hábitos directamente desde inicio o pantalla de bloqueo.

import WidgetKit
import SwiftUI

struct HabitQuickAddEntryView: View {
    var entry: HabitWidgetTimelineProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            accessoryCircularView
        case .accessoryRectangular:
            accessoryRectangularView
        default:
            homeScreenView
        }
    }
    
    // MARK: - Pantalla de Inicio (systemSmall)
    private var homeScreenView: some View {
        VStack(spacing: 10) {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .glassEffect(.regular.tint(Color(hex: "#3B82F6").opacity(0.8)), in: Circle())

            VStack(spacing: 1) {
                Text("Nuevo hábito")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                Text("Crear rutina")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: "habitos://create"))
    }
    
    // MARK: - Pantalla de Bloqueo: Circular
    private var accessoryCircularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            Image(systemName: "plus")
                .font(.title2.bold())
        }
        .widgetURL(URL(string: "habitos://create"))
    }
    
    // MARK: - Pantalla de Bloqueo: Rectangular
    private var accessoryRectangularView: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 1.5)
                    .frame(width: 28, height: 28)
                Image(systemName: "plus")
                    .font(.caption.bold())
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text("HabitOS")
                    .font(.system(size: 10, weight: .bold))
                Text("Nuevo hábito")
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetURL(URL(string: "habitos://create"))
    }
}

struct HabitQuickAddWidget: Widget {
    let kind: String = "HabitQuickAddWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetTimelineProvider()) { entry in
            HabitQuickAddEntryView(entry: entry)
                .containerBackground(for: .widget) { WidgetAurora() }
        }
        .configurationDisplayName("HabitOS — Acceso Rápido")
        .description("Añade un hábito rápidamente desde tu pantalla de inicio o de bloqueo.")
        .supportedFamilies([
            .systemSmall,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}
