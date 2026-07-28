// ──────────────────────────────────────────────
// WidgetTimelineProvider.swift — Proveedor de Datos para WidgetKit
// ──────────────────────────────────────────────
// Genera las líneas de tiempo (TimelineEntry) para refrescar
// los widgets de pantalla de inicio y pantalla de bloqueo.

import WidgetKit
import SwiftUI
import SwiftData

struct DailyActivity: Identifiable {
    let id = UUID()
    let dayLabel: String      // "L", "M", "X", "J", "V", "S", "D"
    let completedCount: Int
    let totalCount: Int
    let isToday: Bool
    
    var percentage: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
    }
}

struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let userName: String
    let userLevel: Int
    let currentXP: Int
    let nextLevelXP: Int
    let activeShields: Int
    let habits: [HabitItemSnapshot]
    let totalStreak: Int
    let weeklyActivity: [DailyActivity]
    let maxStreak: Int
}

struct HabitItemSnapshot: Identifiable {
    let id: String
    let title: String
    let iconName: String
    let colorHex: String
    let isCompletedToday: Bool
    let currentStreak: Int
}

struct HabitWidgetTimelineProvider: TimelineProvider {
    
    typealias Entry = HabitWidgetEntry
    
    // Vista previa en el selector de widgets de iOS
    func placeholder(in context: Context) -> HabitWidgetEntry {
        sampleEntry(date: Date())
    }

    // Datos rápidos para la galería de widgets
    func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
        let entry = fetchCurrentEntry(date: Date())
        completion(entry)
    }

    // Generador principal de la línea de tiempo
    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
        let entry = fetchCurrentEntry(date: Date())
        
        // Actualizamos el widget a la medianoche y cada 15 minutos
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    // Método auxiliar para consultar SwiftData local
    @MainActor
    private func fetchCurrentEntry(date: Date) -> HabitWidgetEntry {
        do {
            let container = ModelContainer.shared
            let context = container.mainContext
            
            let userDescriptor = FetchDescriptor<User>()
            let user = try context.fetch(userDescriptor).first ?? User(email: "hero@habitos.app", name: "Héroe", passwordHash: "local", avatarUrl: "owl:0")
            
            let habitDescriptor = FetchDescriptor<Habit>()
            let allHabits = try context.fetch(habitDescriptor)
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: date)
            
            let habitSnapshots = allHabits.map { habit in
                let isDone = (habit.logs ?? []).contains { calendar.isDate($0.completedAt, inSameDayAs: today) }
                return HabitItemSnapshot(
                    id: habit.id,
                    title: habit.name,
                    iconName: habit.icon ?? "heart.fill",
                    colorHex: habit.color ?? "#018ABE",
                    isCompletedToday: isDone,
                    currentStreak: habit.currentStreak
                )
            }
            
            let currentLevel = user.level
            let nextXP = currentLevel * GamificationEngine.xpPerLevel
            let maxStreak = allHabits.map(\.currentStreak).max() ?? 0
            let bestMaxStreak = allHabits.map(\.maxStreak).max() ?? 0
            let totalShields = allHabits.reduce(0) { $0 + $1.shields }
            
            // Calcular actividad de los últimos 7 días
            let dayLabels = ["D", "L", "M", "X", "J", "V", "S"]
            var weeklyActivity: [DailyActivity] = []
            for offset in (0..<7).reversed() {
                let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
                let weekdayIndex = calendar.component(.weekday, from: day) - 1 // 0=Sunday
                let label = dayLabels[weekdayIndex]
                let totalHabits = allHabits.count
                let completedOnDay = allHabits.filter { habit in
                    (habit.logs ?? []).contains { calendar.isDate($0.completedAt, inSameDayAs: day) }
                }.count
                weeklyActivity.append(DailyActivity(
                    dayLabel: label,
                    completedCount: completedOnDay,
                    totalCount: totalHabits,
                    isToday: offset == 0
                ))
            }
            
            return HabitWidgetEntry(
                date: date,
                userName: user.name ?? "Héroe",
                userLevel: user.level,
                currentXP: user.totalXp,
                nextLevelXP: nextXP,
                activeShields: totalShields,
                habits: Array(habitSnapshots.prefix(4)),
                totalStreak: maxStreak,
                weeklyActivity: weeklyActivity,
                maxStreak: bestMaxStreak
            )
        } catch {
            return sampleEntry(date: date)
        }
    }
    
    private func sampleEntry(date: Date) -> HabitWidgetEntry {
        let sampleWeekly = [
            DailyActivity(dayLabel: "L", completedCount: 3, totalCount: 3, isToday: false),
            DailyActivity(dayLabel: "M", completedCount: 2, totalCount: 3, isToday: false),
            DailyActivity(dayLabel: "X", completedCount: 3, totalCount: 3, isToday: false),
            DailyActivity(dayLabel: "J", completedCount: 1, totalCount: 3, isToday: false),
            DailyActivity(dayLabel: "V", completedCount: 3, totalCount: 3, isToday: false),
            DailyActivity(dayLabel: "S", completedCount: 0, totalCount: 3, isToday: false),
            DailyActivity(dayLabel: "D", completedCount: 2, totalCount: 3, isToday: true)
        ]
        return HabitWidgetEntry(
            date: date,
            userName: "Héroe HabitOS",
            userLevel: 3,
            currentXP: 350,
            nextLevelXP: 600,
            activeShields: 2,
            habits: [
                HabitItemSnapshot(id: UUID().uuidString, title: "Beber 2L de Agua", iconName: "drop.fill", colorHex: "#3A86FF", isCompletedToday: true, currentStreak: 5),
                HabitItemSnapshot(id: UUID().uuidString, title: "Leer 15 min", iconName: "book.fill", colorHex: "#8338EC", isCompletedToday: false, currentStreak: 3),
                HabitItemSnapshot(id: UUID().uuidString, title: "Hacer Ejercicio", iconName: "figure.run", colorHex: "#FF006E", isCompletedToday: false, currentStreak: 12)
            ],
            totalStreak: 12,
            weeklyActivity: sampleWeekly,
            maxStreak: 15
        )
    }
}
