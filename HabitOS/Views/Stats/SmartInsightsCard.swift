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
            // Header del Diagnóstico
            HStack {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(Color(hex: "#8B5CF6"))
                    Text("Diagnóstico Inteligente")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                
                if !isPro {
                    Button {
                        onOpenPaywall()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                            Text("PRO")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundStyle(Color(hex: "#F5A623"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#F5A623").opacity(0.15))
                        .cornerRadius(Radius.sm)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            ZStack {
                VStack(spacing: Spacing.md) {
                    // Item 1: Día de Oro
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#F5A623").opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color(hex: "#F5A623"))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tu Día de Oro")
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.6))
                            Text(bestDayOfWeek)
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    
                    Divider().opacity(0.1)
                    
                    // Item 2: Alerta de Riesgo
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#FF3B30").opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color(hex: "#FF3B30"))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Rachas en Riesgo hoy")
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.6))
                            Text(habitsAtRisk.isEmpty ? "¡Todo bajo control!" : "\(habitsAtRisk.count) hábito(s) pendiente(s)")
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(habitsAtRisk.isEmpty ? Color(hex: "#00F5D4") : Color(hex: "#FF3B30"))
                        }
                        Spacer()
                    }
                    
                    Divider().opacity(0.1)
                    
                    // Item 3: Distribución Horaria
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#00F5D4").opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: morningPercentage >= 50 ? "sun.max.fill" : "moon.stars.fill")
                                .foregroundStyle(Color(hex: "#00F5D4"))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Perfil de Rendimiento")
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.6))
                            Text(morningPercentage >= 50 ? "Mañanero (\(morningPercentage)% completado antes de las 2 PM)" : "Nocturno (\(100 - morningPercentage)% completado por la tarde/noche)")
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                }
                .blur(radius: isPro ? 0 : 6)
                
                // Capa de Bloqueo Pro si no es Pro
                if !isPro {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color(hex: "#F5A623"))
                        Text("Desbloquea el Análisis Inteligente Pro")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                        Button {
                            onOpenPaywall()
                        } label: {
                            Text("Ver Planes Pro")
                                .font(.system(.caption, design: .rounded, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(hex: "#F5A623"))
                                .cornerRadius(Radius.md)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Radius.xl)
                .fill(Color(hex: "#12141C"))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}
