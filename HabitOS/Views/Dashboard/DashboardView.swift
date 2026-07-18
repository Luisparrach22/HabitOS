// ──────────────────────────────────────────────
// DashboardView.swift — Vista principal de Hábitos
// ──────────────────────────────────────────────
// Pantalla principal del usuario.
// Lista los hábitos cargados en SwiftData, divididos
// entre pendientes y completados, junto con un resumen diario.
// Permite completar hábitos directamente y navegar al detalle.

import SwiftUI
import SwiftData

struct DashboardView: View {
    // Inyectamos el contexto de base de datos de SwiftData
    @Environment(\.modelContext) private var modelContext
    
    // Obtenemos todos los hábitos ordenados por fecha de creación
    @Query(sort: \Habit.createdAt, order: .forward) private var habits: [Habit]
    
    // Estados de UI
    @State private var showCompleted = true
    @State private var showingCreateHabitSheet = false
    @State private var selectedHabitForDetail: Habit?
    
    // ── Datos Derivados ───────────────────────────
    
    private var pendingHabits: [Habit] {
        habits.filter { !$0.isCompletedToday }
    }
    
    private var completedHabits: [Habit] {
        habits.filter { $0.isCompletedToday }
    }
    
    private var maxCurrentStreak: Int {
        habits.map(\.currentStreak).max() ?? 0
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Buenos días" }
        if hour < 18 { return "Buenas tardes" }
        return "Buenas noches"
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        return formatter.string(from: Date()).capitalized
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.habBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        
                        // 1. Cabecera (Fecha, Saludo, Avatar)
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dateString)
                                    .font(.habFootnote)
                                    .foregroundStyle(Color.habTextMuted)
                                
                                Text("\(greeting), desarrollador")
                                    .font(.habTitle2)
                                    .foregroundStyle(Color.habTextPrimary)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            // Avatar circular
                            Circle()
                                .fill(Color.habPrimary)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text("D")
                                        .font(.habHeadline)
                                        .foregroundStyle(Color.white)
                                )
                        }
                        .padding(.top, Spacing.sm)
                        
                        // 2. Tarjeta de progreso diario
                        ProgressBar(
                            completedCount: completedHabits.count,
                            totalCount: habits.count,
                            maxCurrentStreak: maxCurrentStreak
                        )
                        
                        // 3. Contenido Principal: Hábitos
                        if habits.isEmpty {
                            // Empty State
                            VStack(spacing: Spacing.md) {
                                Image(systemName: "tree.fill")
                                    .font(.system(size: 64))
                                    .foregroundStyle(Color.habBlueLight)
                                
                                Text("Aún no tienes hábitos")
                                    .font(.habTitle3)
                                    .foregroundStyle(Color.habTextPrimary)
                                
                                Text("¡Empieza a construir tu rutina agregando un nuevo hábito pulsando el botón + arriba!")
                                    .font(.habBody)
                                    .foregroundStyle(Color.habTextMuted)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, Spacing.xl)
                            }
                            .padding(.vertical, Spacing.xl4)
                        } else {
                            // Listado de Hábitos
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                
                                // ── Sección de Pendientes ──
                                if !pendingHabits.isEmpty {
                                    HStack {
                                        Text("Por hacer")
                                            .font(.habHeadline)
                                            .foregroundStyle(Color.habTextSecondary)
                                        Spacer()
                                        Text("\(pendingHabits.count) restantes")
                                            .font(.habCaption)
                                            .foregroundStyle(Color.habTextMuted)
                                    }
                                    
                                    ForEach(pendingHabits) { habit in
                                        HabitCard(
                                            habit: habit,
                                            onCheckin: { toggleCompletion(for: habit) },
                                            onTapGesture: { selectedHabitForDetail = habit }
                                        )
                                    }
                                } else {
                                    // Todo completado
                                    VStack(spacing: Spacing.sm) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 40))
                                            .foregroundStyle(Color.habSuccess)
                                        Text("¡Todo listo por hoy!")
                                            .font(.habHeadline)
                                            .foregroundStyle(Color.habTextPrimary)
                                        Text("¡Gran trabajo!")
                                            .font(.habCaption)
                                            .foregroundStyle(Color.habTextMuted)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Spacing.xl)
                                    .background(Color.habCard.opacity(0.5))
                                    .cornerRadius(Radius.lg)
                                }
                                
                                // ── Sección de Completados ──
                                if !completedHabits.isEmpty {
                                    Button {
                                        withAnimation {
                                            showCompleted.toggle()
                                        }
                                    } label: {
                                        HStack {
                                            Text("✓ Completados (\(completedHabits.count))")
                                                .font(.habHeadline)
                                                .foregroundStyle(Color.habTextSecondary)
                                            Spacer()
                                            Text(showCompleted ? "Ocultar" : "Mostrar")
                                                .font(.habCaption)
                                                .foregroundStyle(Color.habTextMuted)
                                            Image(systemName: showCompleted ? "chevron.up" : "chevron.down")
                                                .font(.caption2)
                                                .foregroundStyle(Color.habTextMuted)
                                        }
                                    }
                                    .padding(.top, Spacing.md)
                                    
                                    if showCompleted {
                                        ForEach(completedHabits) { habit in
                                            HabitCard(
                                                habit: habit,
                                                onCheckin: { toggleCompletion(for: habit) },
                                                onTapGesture: { selectedHabitForDetail = habit }
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl3)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Mi Día")
                        .font(.habHeadline)
                        .foregroundStyle(Color.habTextPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateHabitSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.habPrimary)
                    }
                }
            }
            // Navegación al detalle del hábito (se abre como modal/sheet en este sprint)
            .sheet(item: $selectedHabitForDetail) { habit in
                HabitDetailView(habit: habit)
            }
            // Modal de Creación de Hábito
            .sheet(isPresented: $showingCreateHabitSheet) {
                CreateHabitView()
            }
        }
    }
    
    // Lógica para marcar como completado
    private func toggleCompletion(for habit: Habit) {
        if habit.isCompletedToday {
            // Desmarcar: buscamos el log de hoy y lo eliminamos
            if let todayLog = habit.logs.first(where: { Calendar.current.isDateInToday($0.completedAt) }) {
                modelContext.delete(todayLog)
                habit.currentStreak = max(0, habit.currentStreak - 1)
            }
        } else {
            // Marcar: creamos un nuevo log
            let newLog = HabitLog(habitId: habit.id)
            modelContext.insert(newLog)
            habit.logs.append(newLog)
            habit.currentStreak += 1
            if habit.currentStreak > habit.maxStreak {
                habit.maxStreak = habit.currentStreak
            }
        }
        
        // Guardamos los cambios en SwiftData
        try? modelContext.save()
    }
}

// MARK: - Previsualización

#Preview {
    DashboardView()
        .modelContainer(for: [Habit.self, User.self], inMemory: true)
}
