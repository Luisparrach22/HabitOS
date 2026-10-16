// ──────────────────────────────────────────────
// StatsView.swift — Pantalla de Estadísticas y Métricas
// ──────────────────────────────────────────────
// Muestra gráficos de rendimiento semanal, tasa de cumplimiento
// global y mapa de calor de consistencia utilizando Swift Charts.

import SwiftUI
import SwiftData
import Charts

struct DailyStat: Identifiable {
    let id = UUID()
    let dayName: String
    let date: Date
    let count: Int
}

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var habits: [Habit]
    @Query private var habitsLogs: [HabitLog]
    @Query private var users: [User]
    
    @State private var showingPaywall = false
    @AppStorage("currentUserId") private var currentUserId: String = ""
    
    private var currentUser: User? {
        users.first(where: { $0.id == currentUserId }) ?? users.first
    }
    
    private var isUserPro: Bool {
        currentUser?.isPro ?? false
    }
    
    // ── Datos Derivados ───────────────────────────
    
    private var userHabits: [Habit] {
        habits.filter { $0.userId == currentUser?.id }
    }
    
    private var userHabitsLogs: [HabitLog] {
        let userHabitIds = Set(userHabits.map(\.id))
        return habitsLogs.filter { userHabitIds.contains($0.habitId) }
    }
    
    private var totalCompletedLogs: Int {
        userHabitsLogs.count
    }
    
    private var maxStreak: Int {
        userHabits.map(\.maxStreak).max() ?? 0
    }
    
    private var globalCompletionRate: Int {
        guard !userHabits.isEmpty else { return 0 }
        let totalPossibleDays = max(1, userHabits.count * 30)
        let rate = Double(totalCompletedLogs) / Double(totalPossibleDays) * 100
        return min(100, max(0, Int(rate)))
    }
    
    // Genera estadísticas de los últimos 7 días para el gráfico
    private var weeklyStats: [DailyStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "es_ES")
        dayFormatter.dateFormat = "EEE"
        
        var stats: [DailyStat] = []
        
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let dayName = dayFormatter.string(from: date).capitalized
            let logsCount = userHabitsLogs.filter { calendar.isDate($0.completedAt, inSameDayAs: date) }.count
            stats.append(DailyStat(dayName: dayName, date: date, count: logsCount))
        }
        
        return stats
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuroraBackground()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.xl2) {
                        
                        // 1. Métricas clave: una lista agrupada
                        VStack(spacing: 0) {
                            KpiRow(title: "Completados", value: "\(totalCompletedLogs)", icon: "checkmark.circle.fill", iconColor: .habSuccess)
                            Divider().padding(.leading, 56)
                            KpiRow(title: "Mejor racha", value: "\(maxStreak) días", icon: "flame.fill", iconColor: .habWarning)
                            Divider().padding(.leading, 56)
                            KpiRow(title: "Consistencia", value: "\(globalCompletionRate)%", icon: "chart.line.uptrend.xyaxis", iconColor: .habPrimary)
                            Divider().padding(.leading, 56)
                            KpiRow(title: "XP total", value: "\(currentUser?.totalXp ?? 0)", icon: "star.fill", iconColor: .habWarning)
                        }
                        .glassCard(Radius.lg)
                        
                        // 2. Gráfico semanal
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Esta semana")
                                .font(.title3.weight(.semibold))
                            
                            Chart(weeklyStats) { stat in
                                BarMark(
                                    x: .value("Día", stat.dayName),
                                    y: .value("Hábitos", stat.count)
                                )
                                .cornerRadius(4)
                                .foregroundStyle(Color.habPrimary)
                            }
                            .frame(height: 180)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                        }
                        .padding(Spacing.lg)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassCard(Radius.lg)
                        
                        // 2b. Diagnóstico
                        SmartInsightsCard(
                            habits: userHabits,
                            isPro: isUserPro,
                            onOpenPaywall: {
                                showingPaywall = true
                            }
                        )
                        
                        // 3. Calendario del mes
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Este mes")
                                .font(.title3.weight(.semibold))
                            
                            ZStack {
                                MonthHeatmapGrid(logs: userHabitsLogs, habitsCount: userHabits.count)
                                    .blur(radius: isUserPro ? 0 : 5)
                                    .disabled(!isUserPro)
                                    .accessibilityHidden(!isUserPro)
                                
                                if !isUserPro {
                                    VStack(spacing: Spacing.sm) {
                                        Image(systemName: "lock.fill")
                                            .foregroundStyle(Color.secondary)
                                        Text("Disponible con Pro")
                                            .font(.subheadline)
                                        Button("Desbloquear") {
                                            showingPaywall = true
                                        }
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassCard(Radius.lg)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.sm)
                    .padding(.bottom, Spacing.xl3)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            }
            .navigationTitle("Estadísticas")
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

// MARK: - Fila de métrica
struct KpiRow: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(iconColor, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .accessibilityHidden(true)
            Text(title)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body.monospacedDigit())
                .foregroundStyle(Color.secondary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Rejilla de Consistencia Mensual Rediseñada
struct MonthHeatmapGrid: View {
    let logs: [HabitLog]
    let habitsCount: Int
    
    private let calendar = Calendar.current
    private let now = Date()
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let weekdayHeaders = ["L", "M", "X", "J", "V", "S", "D"]
    
    private var year: Int {
        calendar.component(.year, from: now)
    }
    
    private var month: Int {
        calendar.component(.month, from: now)
    }
    
    private var daysInMonth: Int {
        guard let range = calendar.range(of: .day, in: .month, for: now) else {
            return 30
        }
        return range.count
    }
    
    private var firstWeekdayOffset: Int {
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return 0
        }
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        // Mapear Domingo (1) a 6, Lunes (2) a 0, Martes (3) a 1...
        return (weekday + 5) % 7
    }
    
    private var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: now).capitalized
    }
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Nombre del mes y año dinámico
            Text(currentMonthName)
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
            
            // Cabeceras de los días de la semana
            HStack(spacing: 0) {
                ForEach(weekdayHeaders, id: \.self) { header in
                    Text(header)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 2)
            
            LazyVGrid(columns: columns, spacing: 6) {
                // Rellenar días vacíos (offset) del inicio de mes con IDs de tipo String para evitar colisiones
                ForEach(Array(0..<firstWeekdayOffset).map { "offset-\($0)" }, id: \.self) { _ in
                    Color.clear
                        .frame(height: 32)
                }
                
                // Días reales del mes
                ForEach(1...daysInMonth, id: \.self) { dayNumber in
                    let completedCount = completedLogsCount(for: dayNumber)
                    let intensity = habitsCount > 0 ? Double(completedCount) / Double(habitsCount) : 0.0
                    let hasLog = completedCount > 0
                    
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(hasLog ? Color.habPrimary.opacity(0.25 + intensity * 0.75) : Color.primary.opacity(0.05))
                        .frame(height: 32)
                        .overlay(
                            Text("\(dayNumber)")
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(hasLog ? Color.white : Color.secondary)
                        )
                }
            }
        }
    }
    
    private func completedLogsCount(for dayNumber: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = dayNumber
        guard let date = calendar.date(from: components) else { return 0 }
        
        return logs.filter { calendar.isDate($0.completedAt, inSameDayAs: date) }.count
    }
}

// MARK: - Previsualización
#Preview {
    StatsView()
        .modelContainer(for: [Habit.self, HabitLog.self, User.self], inMemory: true)
}
