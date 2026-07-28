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
        VStack(spacing: 8) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(hex: "#7B2CBF"), Color(hex: "#00F5D4")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 52, height: 52)
                    .shadow(color: Color(hex: "#00F5D4").opacity(0.3), radius: 6)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("Nuevo Hábito")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Crear rutina rápida")
                .font(.system(size: 9))
                .foregroundColor(.gray)
                .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#0D0F14"))
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
                Text("Nuevo Hábito")
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
