// Glass.swift — Liquid Glass + fondo "Aurora"
// Identidad visual: un fondo vivo de malla de color sobre el que flotan
// superficies de cristal líquido (iOS 26). El color vive detrás; el cristal
// lo refracta, así la interfaz se siente ligera y profunda a la vez.

import SwiftUI

// MARK: - Fondo Aurora

struct AuroraBackground: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var colors: [Color] {
        if scheme == .dark {
            return [
                Color(hex: "#070B1F"), Color(hex: "#1B1B66"), Color(hex: "#0A1230"),
                Color(hex: "#0C3A78"), Color(hex: "#1E6FC0"), Color(hex: "#4A1F86"),
                Color(hex: "#06141F"), Color(hex: "#0E6270"), Color(hex: "#0A1026")
            ]
        } else {
            return [
                Color(hex: "#E8F2FF"), Color(hex: "#EFE6FF"), Color(hex: "#E3F5FF"),
                Color(hex: "#C9E4FF"), Color(hex: "#D9E8FF"), Color(hex: "#E9DAFF"),
                Color(hex: "#DDF6EE"), Color(hex: "#CDEBFA"), Color(hex: "#F1EAFF")
            ]
        }
    }

    private func points(_ t: Double) -> [SIMD2<Float>] {
        func d(_ phase: Double, _ amp: Double) -> Float { Float(sin(t * 0.22 + phase) * amp) }
        return [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5 + d(2, 0.08)],
            [0.5 + d(3, 0.12), 0.5 + d(4, 0.10)],
            [1, 0.5 + d(6, 0.08)],
            [0, 1], [0.5, 1], [1, 1]
        ]
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 15.0, paused: reduceMotion)) { context in
            let t = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
            MeshGradient(width: 3, height: 3, points: points(t), colors: colors)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Superficies de cristal

extension View {
    /// Tarjeta de cristal líquido. `tint` añade un matiz suave de color.
    func glassCard(_ radius: CGFloat = Radius.lg, tint: Color? = nil, interactive: Bool = false) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        var glass: Glass = .regular
        if let tint { glass = glass.tint(tint.opacity(0.28)) }
        if interactive { glass = glass.interactive() }
        return self.glassEffect(glass, in: shape)
    }

    /// Fondo de fila para listas agrupadas sobre el fondo Aurora.
    func glassListRow() -> some View {
        self.listRowBackground(Rectangle().fill(.thinMaterial))
    }

    /// Lista sobre Aurora: oculta el fondo del sistema y pinta la malla.
    func auroraList() -> some View {
        self.scrollContentBackground(.hidden)
            .background { AuroraBackground() }
    }
}

// MARK: - Anillo de progreso

struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 14
    var colors: [Color] = [Color(hex: "#31D0F5"), Color(hex: "#3B82F6"), Color(hex: "#A855F7")]

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(progress, 0.001))
                .stroke(
                    AngularGradient(colors: colors + [colors[0]], center: .center, startAngle: .degrees(0), endAngle: .degrees(360)),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: colors[1].opacity(0.45), radius: 8, y: 2)
                .animation(.smooth(duration: 0.8), value: progress)
        }
    }
}
