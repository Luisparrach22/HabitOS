// ──────────────────────────────────────────────
// DashboardView.swift — Vista principal de Hábitos
// ──────────────────────────────────────────────
// Pantalla principal del usuario.
// Lista los hábitos cargados en SwiftData, divididos
// entre pendientes y completados, junto con un resumen diario y gamificación.

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Habit.createdAt, order: .forward) private var habits: [Habit]
    @Query private var users: [User]
    
    @State private var viewModel = HabitViewModel()
    
    @State private var showCompleted = true
    @State private var showingCreateHabitSheet = false
    @State private var showingPaywall = false
    @State private var selectedHabitForDetail: Habit?
    @AppStorage("currentUserId") private var currentUserId: String = ""
    
    private var currentUser: User? {
        users.first(where: { $0.id == currentUserId }) ?? users.first
    }
    
    private var userHabits: [Habit] {
        habits.filter { $0.userId == currentUser?.id }
    }
    
    private var pendingHabits: [Habit] {
        userHabits.filter { !$0.isCompletedToday }
    }
    
    private var completedHabits: [Habit] {
        userHabits.filter { $0.isCompletedToday }
    }
    
    private var maxCurrentStreak: Int {
        userHabits.map(\.currentStreak).max() ?? 0
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
        let text = formatter.string(from: Date())
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuroraBackground()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.xl2) {
                        
                        // 1. Cabecera
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dateString)
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            Text("\(greeting), \(currentUser?.name ?? "Guerrero")")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.xs)

                        // 2. Tarjeta de progreso diario
                        ProgressBar(
                            completedCount: completedHabits.count,
                            totalCount: userHabits.count,
                            maxCurrentStreak: maxCurrentStreak
                        )
                        
                        // 2b. Misión Boss Battle Semanal
                        BossBattleCard(
                            habits: userHabits,
                            user: currentUser,
                            onClaimReward: {
                                if let user = currentUser {
                                    GamificationEngine.addBonusXP(amount: 200, to: user, context: modelContext)
                                }
                            }
                        )
                        
                        // 3. Hábitos
                        if userHabits.isEmpty {
                            emptyStateView
                        } else {
                            habitsListView
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl3)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            }
            .navigationTitle("Mi Día")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        let isPro = currentUser?.isPro ?? false
                        if !isPro && userHabits.count >= 5 {
                            showingPaywall = true
                        } else {
                            showingCreateHabitSheet = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .onAppear {
                viewModel.ensureDefaultUser(context: modelContext)
            }
            .alert("Subiste de nivel", isPresented: $viewModel.showLevelUpAlert) {
                Button("¡Genial!", role: .cancel) { }
            } message: {
                if let result = viewModel.lastLevelUpResult {
                    Text("¡Has alcanzado el Nivel \(result.newLevel)! Se ha otorgado \(result.shieldsAwarded) escudo adicional para proteger tu racha.")
                } else {
                    Text("¡Subiste de nivel!")
                }
            }
            .sheet(item: $selectedHabitForDetail) { habit in
                HabitDetailView(habit: habit)
            }
            .sheet(isPresented: $showingCreateHabitSheet) {
                CreateHabitView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
    
    // Vista del listado de hábitos
    private var habitsListView: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            
            // ── Sección de Pendientes ──
            if !pendingHabits.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("Por hacer")
                            .font(.title3.weight(.semibold))
                        Spacer()
                        Text("\(pendingHabits.count)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.horizontal, Spacing.xs)
                    
                    habitGroup(pendingHabits)
                }
            } else {
                // Todo completado
                VStack(spacing: Spacing.md) {
                    Image(systemName: "checkmark.circle")
                        .font(.largeTitle)
                        .foregroundStyle(Color.habSuccess)
                    
                    Text("Todo listo por hoy")
                        .font(.headline)
                    
                    Text("Vuelve mañana para continuar tu racha.")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
                .glassCard(Radius.lg)
            }
            
            // ── Sección de Completados ──
            if !completedHabits.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showCompleted.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Completados")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Color.primary)
                            Text("\(completedHabits.count)")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            Spacer()
                            Image(systemName: "chevron.up")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.secondary)
                                .rotationEffect(.degrees(showCompleted ? 0 : 180))
                        }
                        .padding(.horizontal, Spacing.xs)
                    }
                    .buttonStyle(.plain)
                    
                    if showCompleted {
                        habitGroup(completedHabits)
                    }
                }
            }
        }
    }
    
    // Vista de estado vacío
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("Comienza tu rutina", systemImage: "checklist")
        } description: {
            Text("Toca + para añadir tu primer hábito.")
        }
        .padding(.vertical, Spacing.xl3)
    }

    // Hábitos como cristales flotantes que se funden al acercarse
    private func habitGroup(_ items: [Habit]) -> some View {
        GlassEffectContainer(spacing: 14) {
            VStack(spacing: Spacing.sm) {
                ForEach(items) { habit in
                    HabitCard(
                        habit: habit,
                        onCheckin: { toggleCompletion(for: habit) },
                        onTapGesture: { selectedHabitForDetail = habit }
                    )
                }
            }
        }
    }
    
    private func toggleCompletion(for habit: Habit) {
        viewModel.toggleCompletion(for: habit, user: currentUser, context: modelContext)
    }
}

// MARK: - Previsualización
#Preview {
    DashboardView()
        .modelContainer(for: [Habit.self, User.self], inMemory: true)
}
