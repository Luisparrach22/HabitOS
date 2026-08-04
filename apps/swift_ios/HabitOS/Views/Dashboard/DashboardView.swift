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
        return formatter.string(from: Date()).capitalized
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.habBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.xl) {
                        
                        // 1. Cabecera (Fecha y Saludo)
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dateString)
                                    .font(.system(.footnote, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.secondary)
                                
                                Text("\(greeting), \(currentUser?.name ?? "Guerrero")")
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.primary)
                            }
                            
                            Spacer()
                            
                            // Badge de Nivel del Usuario (Avatar HIG)
                            if let user = currentUser {
                                NavigationLink(destination: ProfileView()) {
                                    HStack(spacing: 8) {
                                        VStack(alignment: .trailing, spacing: 1) {
                                            Text("NV. \(user.level)")
                                                .font(.system(size: 11, weight: .black, design: .rounded))
                                                .foregroundStyle(Color.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(
                                                    Capsule()
                                                        .fill(LinearGradient(colors: [Color(hex: "#7B2CBF"), Color(hex: "#00F5D4")], startPoint: .leading, endPoint: .trailing))
                                                )
                                        }
                                        
                                        AvatarView(avatarString: user.avatarUrl, size: 36)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, Spacing.sm)
                        
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
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.habPrimary)
                    }
                }
            }
            .onAppear {
                viewModel.ensureDefaultUser(context: modelContext)
            }
            .alert("¡Nivel Conquistado! 🎉", isPresented: $viewModel.showLevelUpAlert) {
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
                        Text("POR HACER")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        Text("\(pendingHabits.count) restantes")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.secondary.opacity(0.8))
                    }
                    .padding(.horizontal, Spacing.xs)
                    
                    ForEach(pendingHabits) { habit in
                        HabitCard(
                            habit: habit,
                            onCheckin: { toggleCompletion(for: habit) },
                            onTapGesture: { selectedHabitForDetail = habit }
                        )
                    }
                }
            } else {
                // Todo completado
                VStack(spacing: Spacing.md) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.habSuccess)
                    
                    Text("¡Todo listo por hoy!")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                    
                    Text("¡Gran trabajo acumulando XP!")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
                .background(Color.habCard.opacity(0.4))
                .cornerRadius(Radius.lg)
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
                            Text("COMPLETADOS (\(completedHabits.count))")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                            Spacer()
                            Image(systemName: "chevron.up")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.secondary)
                                .rotationEffect(.degrees(showCompleted ? 0 : 180))
                        }
                        .padding(.horizontal, Spacing.xs)
                    }
                    .buttonStyle(.plain)
                    
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
    
    // Vista de estado vacío
    private var emptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            ZStack {
                Circle()
                    .fill(Color.habPrimary.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: "checklist")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.habPrimary)
            }
            
            Text("Comienza tu rutina")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(Color.primary)
            
            Text("Añade hábitos diarios pulsando el botón + arriba para iniciar tu camino hacia la disciplina.")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl2)
        }
        .padding(.vertical, Spacing.xl4)
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
