// ──────────────────────────────────────────────
// SmartInsightsCard.swift — Diagnóstico Inteligente Pro
// ──────────────────────────────────────────────
// Analiza el historial de completados (HabitLog) para calcular:
// 1. El día más productivo de la semana ("Día de Oro").
// 2. Hábitos con racha alta en riesgo hoy.
// 3. Patrón de completado (Mañana vs Noche).

import SwiftUI

struct SmartInsightsCard: View {
    let habits: [Habit]
    let isPro: Bool
    let onOpenPaywall: () -> Void
    
    // Cálculo del Día de Oro
    private var bestDayOfWeek: String {
        let calendar = Calendar.current
        var dayCounts: [Int: Int] = [:] // 1: Dom, 2: Lun ... 7: Sáb
        
        for habit in habits {
            for log in habit.logs ?? [] {
                let weekday = calendar.component(.weekday, from: log.completedAt)
                dayCounts[weekday, default: 0] += 1
            }
        }
        
        guard let maxDay = dayCounts.max(by: { $0.value < $1.value })?.key else {
            return "Sin datos suficientes"
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        let dayName = formatter.weekdaySymbols[maxDay - 1].capitalized
        return dayName
    }
    
    // Hábitos en riesgo hoy (racha > 2 y aún no completados hoy)
    private var habitsAtRisk: [Habit] {
        habits.filter { $0.currentStreak >= 2 && !$0.isCompletedToday }
    }
    
    // Porcentaje de mañana vs tarde/noche
    private var morningPercentage: Int {
        let allLogs = habits.flatMap { $0.logs ?? [] }
        guard !allLogs.isEmpty else { return 50 }
        
        let morningLogs = allLogs.filter {
            let hour = Calendar.current.component(.hour, from: $0.completedAt)
            return hour >= 6 && hour < 14
        }
        
        return Int((Double(morningLogs.count) / Double(allLogs.count)) * 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Diagnóstico")
                    .font(.title3.weight(.semibold))
                Spacer()
                if !isPro {
                    Label("Pro", systemImage: "lock.fill")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.secondary)
                }
            }

            ZStack {
                VStack(spacing: 0) {
                    insightRow(icon: "star.fill", color: .habWarning, title: "Tu mejor día", value: bestDayOfWeek)
                    Divider().padding(.leading, 44)
                    insightRow(
                        icon: "exclamationmark.triangle.fill",
                        color: habitsAtRisk.isEmpty ? .habSuccess : .habDanger,
                        title: "Rachas en riesgo",
                        value: habitsAtRisk.isEmpty ? "Todo bajo control" : "\(habitsAtRisk.count) pendiente(s)"
                    )
                    Divider().padding(.leading, 44)
                    insightRow(
                        icon: morningPercentage >= 50 ? "sun.max.fill" : "moon.stars.fill",
                        color: .habPrimary,
                        title: "Rendimiento",
                        value: morningPercentage >= 50 ? "Mañanero · \(morningPercentage)% antes de las 14:00" : "Nocturno · \(100 - morningPercentage)% por la tarde y noche"
                    )
                }
                .blur(radius: isPro ? 0 : 6)
                .accessibilityHidden(!isPro)

                if !isPro {
                    VStack(spacing: Spacing.sm) {
                        Text("Análisis disponible con Pro")
                            .font(.subheadline)
                        Button("Ver planes") { onOpenPaywall() }
                            .buttonStyle(.glassProminent)
                            .controlSize(.small)
                            .tint(Color.habPrimary)
                    }
                    .padding(Spacing.lg)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                }
            }
        }
        .padding(Spacing.lg)
        .glassCard(Radius.lg)
    }

    private func insightRow(icon: String, color: Color, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                Text(value)
                    .font(.body)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, Spacing.sm)
        .accessibilityElement(children: .combine)
    }
}
