// WidgetGlass.swift — Identidad Liquid Glass compartida por los widgets
// Fondo Aurora estático (los widgets no animan) + anillo + chips de cristal.

import SwiftUI
import WidgetKit

struct WidgetAurora: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.55, 0.45], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: scheme == .dark
                ? [Color(hex: "#070B1F"), Color(hex: "#1B1B66"), Color(hex: "#0A1230"),
                   Color(hex: "#0C3A78"), Color(hex: "#1E6FC0"), Color(hex: "#4A1F86"),
                   Color(hex: "#06141F"), Color(hex: "#0E6270"), Color(hex: "#0A1026")]
                : [Color(hex: "#E8F2FF"), Color(hex: "#EFE6FF"), Color(hex: "#E3F5FF"),
                   Color(hex: "#BFDFFF"), Color(hex: "#CFE2FF"), Color(hex: "#E2D2FF"),
                   Color(hex: "#DDF6EE"), Color(hex: "#C4E7FA"), Color(hex: "#F1EAFF")]
        )
    }
}

struct WidgetRing: View {
    let progress: Double
    var lineWidth: CGFloat = 9

    var body: some View {
        ZStack {
            Circle().stroke(Color.primary.opacity(0.10), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, min(1, progress)))
                .stroke(
                    AngularGradient(
                        colors: [Color(hex: "#31D0F5"), Color(hex: "#3B82F6"), Color(hex: "#A855F7"), Color(hex: "#31D0F5")],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

extension View {
    /// Chip de cristal para datos secundarios.
    func widgetChip() -> some View {
        self.padding(.horizontal, 9)
            .padding(.vertical, 4)
            .glassEffect(.regular, in: Capsule())
    }
}
