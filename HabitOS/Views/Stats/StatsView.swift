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
    
    private var currentUser: User? {
        users.first
    }
    
    private var isUserPro: Bool {
        currentUser?.isPro ?? false
    }
    
    // ── Datos Derivados ───────────────────────────
    
    private var totalCompletedLogs: Int {
        habitsLogs.count
    }
    
    private var maxStreak: Int {
        habits.map(\.maxStreak).max() ?? 0
    }
    
    private var globalCompletionRate: Int {
        guard !habits.isEmpty else { return 0 }
        let totalPossibleDays = max(1, habits.count * 30)
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
            let logsCount = habitsLogs.filter { calendar.isDate($0.completedAt, inSameDayAs: date) }.count
            stats.append(DailyStat(dayName: dayName, date: date, count: logsCount))
        }
        
        return stats
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.habBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.xl) {
                        
                        // 1. Tarjetas KPI de Métricas Clave
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                            KpiCard(
                                title: "Completados",
                                value: "\(totalCompletedLogs)",
                                unit: "hábitos en total",
                                icon: "checkmark.seal.fill",
                                iconColor: .habSuccess
                            )
                            
                            KpiCard(
                                title: "Mejor Racha",
                                value: "\(maxStreak)",
                                unit: "días consecutivos",
                                icon: "flame.fill",
                                iconColor: .habWarning
                            )
                            
                            KpiCard(
                                title: "Consistencia",
                                value: "\(globalCompletionRate)%",
                                unit: "tasa de éxito",
                                icon: "chart.line.uptrend.xyaxis",
                                iconColor: .habPrimary
                            )
                            
                            KpiCard(
                                title: "XP Total",
                                value: "\(currentUser?.totalXp ?? 0)",
                                unit: "puntos acumulados",
                                icon: "star.fill",
                                iconColor: .habWarning
                            )
                        }
                        .padding(.top, Spacing.sm)
                        
                        // 2. Gráfico de Actividad Semanal (Swift Charts)
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundStyle(Color.habPrimary)
                                    .font(.subheadline)
                                Text("Rendimiento Semanal")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.primary)
                                Spacer()
                            }
                            
                            Chart(weeklyStats) { stat in
                                BarMark(
                                    x: .value("Día", stat.dayName),
                                    y: .value("Hábitos", stat.count)
                                )
                                .cornerRadius(4)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#7B2CBF"), Color(hex: "#00F5D4")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                            .frame(height: 180)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                        }
                        .padding(18)
                        .background(Color.habCard)
                        .cornerRadius(Radius.xl2)
                        .shadow(color: Color.black.opacity(0.01), radius: 6, x: 0, y: 3)
                        
                        // 2b. Diagnóstico Inteligente de Consistencia
                        SmartInsightsCard(
                            habits: habits,
                            isPro: isUserPro,
                            onOpenPaywall: {
                                showingPaywall = true
                            }
                        )
                        
                        // 3. Mapa de Calor (Heatmap / Calendario de Consistencia)
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundStyle(Color.habPrimary)
                                    .font(.subheadline)
                                Text("Consistencia del Mes")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.primary)
                                Spacer()
                            }
                            
                            ZStack {
                                MonthHeatmapGrid(logs: habitsLogs, habitsCount: habits.count)
                                    .blur(radius: isUserPro ? 0 : 5)
                                    .disabled(!isUserPro)
                                
                                if !isUserPro {
                                    VStack(spacing: Spacing.xs) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(Color.habPrimary)
                                        Text("Rejilla de Consistencia")
                                            .font(.system(.caption, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.primary)
                                        Button {
                                            showingPaywall = true
                                        } label: {
                                            Text("Desbloquear con Pro")
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    LinearGradient(
                                                        colors: [Color(hex: "#8B5CF6"), Color(hex: "#EC4899")],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(12)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(12)
                                    .background(Color.habCard.opacity(0.85))
                                    .cornerRadius(Radius.md)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                                }
                            }
                        }
                        .padding(18)
                        .background(Color.habCard)
                        .cornerRadius(Radius.xl2)
                        .shadow(color: Color.black.opacity(0.01), radius: 6, x: 0, y: 3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Spacing.lg)
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

// MARK: - Tarjeta KPI Premium
struct KpiCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(iconColor)
                }
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primary)
                .padding(.top, 4)
            
            Text(title)
                .font(.system(.footnote, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(Color.secondary)
            
            Text(unit)
                .font(.system(size: 10))
                .foregroundStyle(Color.secondary.opacity(0.8))
        }
        .padding(14)
        .background(Color.habCard)
        .cornerRadius(Radius.lg)
        .shadow(color: Color.black.opacity(0.01), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(Color.primary.opacity(0.04), lineWidth: 1)
        )
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
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
            
            // Cabeceras de los días de la semana
            HStack(spacing: 0) {
                ForEach(weekdayHeaders, id: \.self) { header in
                    Text(header)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary.opacity(0.6))
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
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(hasLog ? Color.habPrimary.opacity(0.2 + intensity * 0.8) : Color.primary.opacity(0.04))
                        .frame(height: 32)
                        .overlay(
                            Text("\(dayNumber)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
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
