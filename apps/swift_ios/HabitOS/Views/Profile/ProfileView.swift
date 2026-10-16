// ──────────────────────────────────────────────
// ProfileView.swift — Perfil de Usuario y Gamificación
// ──────────────────────────────────────────────
// Pantalla de usuario que incluye nivel actual, progreso de XP,
// inventario de escudos, muro de insignias y ajustes de la app.

import SwiftUI
import SwiftData

enum AchievementCategory: String, CaseIterable, Identifiable {
    case all = "Todos"
    case consistency = "Rachas"
    case level = "Niveles"
    case specials = "Especiales"
    case routine = "Rutina"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .consistency: return "flame.fill"
        case .level: return "crown.fill"
        case .specials: return "star.fill"
        case .routine: return "checklist"
        }
    }
}

struct Achievement: Identifiable {
    var id: String { title }
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let color: Color
    let isUnlocked: Bool
}

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var users: [User]
    @Query private var habits: [Habit]
    @AppStorage("appThemeMode") private var appThemeMode: String = "system"
    @AppStorage("selectedGlobalTheme") private var selectedGlobalTheme: String = "Original"
    
    @State private var currentAppIcon: String = "default"
    @State private var showingEditProfile = false
    @State private var showingAvatarPicker = false
    @State private var selectedCategory: AchievementCategory = .all
    @State private var showingShieldShop = false
    @State private var showingPaywall = false
    @State private var showingAllAchievements = false
    
    @AppStorage("currentUserId") private var currentUserId: String = ""
    
    private var currentUser: User? {
        users.first(where: { $0.id == currentUserId })
    }
    
    private var userHabits: [Habit] {
        habits.filter { $0.userId == currentUser?.id }
    }
    
    private var totalShieldsCount: Int {
        userHabits.reduce(0) { $0 + $1.shields }
    }
    
    // Lista de Insignias / Logros del Usuario
    private var achievements: [Achievement] {
        let totalXp = currentUser?.totalXp ?? 0
        let currentLevel = currentUser?.level ?? 1
        let maxStreak = userHabits.map(\.maxStreak).max() ?? 0
        let habitsCount = userHabits.count
        
        let logs = userHabits.flatMap { $0.logs ?? [] }
        let totalShieldLogsCount = userHabits.reduce(0) { $0 + ($1.shieldLogs ?? []).count }
        
        let hasCompletedBefore8AM = logs.contains { log in
            let hour = Calendar.current.component(.hour, from: log.completedAt)
            return hour < 8
        }
        
        let hasCompletedAfter10PM = logs.contains { log in
            let hour = Calendar.current.component(.hour, from: log.completedAt)
            return hour >= 22
        }
        
        let hasTriggerHabit = userHabits.contains { $0.trigger != nil && !$0.trigger!.isEmpty }
        
        return [
            // ── CONSISTENCIA ──
            Achievement(title: "La Chispa", description: "Completa un hábito 3 días seguidos", icon: "flame", category: .consistency, color: .orange, isUnlocked: maxStreak >= 3),
            Achievement(title: "Ritmo Constante", description: "Mantén una racha de 7 días", icon: "calendar.badge.clock", category: .consistency, color: Color(hex: "#FF9F00"), isUnlocked: maxStreak >= 7),
            Achievement(title: "Inquebrantable", description: "Mantén una racha de 30 días", icon: "bolt.shield.fill", category: .consistency, color: Color(hex: "#FF3B30"), isUnlocked: maxStreak >= 30),
            Achievement(title: "Leyenda Disciplinada", description: "Mantén una racha de 90 días", icon: "crown.fill", category: .consistency, color: Color(hex: "#FFD60A"), isUnlocked: maxStreak >= 90),
            
            // ── PROGRESO Y XP ──
            Achievement(title: "Primer Paso", description: "Completa tu primer hábito", icon: "sparkles", category: .level, color: Color(hex: "#00F5D4"), isUnlocked: totalXp > 0),
            Achievement(title: "Guerrero Nivel 5", description: "Llega al nivel 5 de experiencia", icon: "shield.lefthalf.filled", category: .level, color: Color(hex: "#30A2FF"), isUnlocked: currentLevel >= 5),
            Achievement(title: "Centurión", description: "Acumula 1,000 XP totales", icon: "medal.fill", category: .level, color: Color(hex: "#BF5AF2"), isUnlocked: totalXp >= 1000),
            Achievement(title: "Soberano de Hábitos", description: "Llega al nivel 10 de experiencia", icon: "trophy.fill", category: .level, color: Color(hex: "#FFCC00"), isUnlocked: currentLevel >= 10),
            
            // ── RECUPERACIÓN Y TIEMPOS ──
            Achievement(title: "Escudo Protector", description: "Usa un escudo para salvar tu racha", icon: "shield.fill", category: .specials, color: Color(hex: "#018ABE"), isUnlocked: totalShieldLogsCount >= 1),
            Achievement(title: "Resiliencia Fénix", description: "Usa 3 escudos en total", icon: "heart.text.square.fill", category: .specials, color: Color(hex: "#FF2D55"), isUnlocked: totalShieldLogsCount >= 3),
            Achievement(title: "Madrugador", description: "Completa un hábito antes de las 8:00 AM", icon: "sunrise.fill", category: .specials, color: Color(hex: "#FF9F0A"), isUnlocked: hasCompletedBefore8AM),
            Achievement(title: "Búho Nocturno", description: "Completa un hábito después de las 10:00 PM", icon: "moon.stars.fill", category: .specials, color: Color(hex: "#5856D6"), isUnlocked: hasCompletedAfter10PM),
            
            // ── DISEÑO DE RUTINAS ──
            Achievement(title: "Creador de Hábitos", description: "Crea tu primer hábito personalizado", icon: "plus.circle.fill", category: .routine, color: Color(hex: "#34C759"), isUnlocked: habitsCount >= 1),
            Achievement(title: "Arquitecto de Rutinas", description: "Ten 5 hábitos activos a la vez", icon: "square.grid.3x3.fill", category: .routine, color: Color(hex: "#30A2FF"), isUnlocked: habitsCount >= 5),
            Achievement(title: "Stacker Maestro", description: "Configura un disparador de hábito", icon: "link", category: .routine, color: Color(hex: "#AF52DE"), isUnlocked: hasTriggerHabit)
        ]
    }
    
    private var filteredAchievements: [Achievement] {
        if selectedCategory == .all {
            return achievements
        } else {
            return achievements.filter { $0.category == selectedCategory }
        }
    }
    
    private var unlockedCount: Int {
        achievements.filter(\.isUnlocked).count
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Cabecera de perfil
                Section {
                    VStack(spacing: Spacing.md) {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            showingAvatarPicker = true
                        } label: {
                            AvatarView(avatarString: currentUser?.avatarUrl, size: 80)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Cambiar avatar")

                        VStack(spacing: 2) {
                            Text(currentUser?.name ?? "Desarrollador HabitOS")
                                .font(.title3.weight(.semibold))
                            Text(currentUser?.email ?? "usuario@habitos.app")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        }

                        let currentXP = GamificationEngine.xpInCurrentLevel(totalXP: currentUser?.totalXp ?? 0)
                        let xpLimit = GamificationEngine.xpPerLevel
                        let fraction = GamificationEngine.levelProgressFraction(totalXP: currentUser?.totalXp ?? 0)

                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            HStack {
                                Text("Nivel \(currentUser?.level ?? 1)")
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                Text("\(currentXP) / \(xpLimit) XP")
                                    .font(.footnote.monospacedDigit())
                                    .foregroundStyle(Color.secondary)
                            }
                            ProgressView(value: fraction)
                                .tint(Color.habPrimary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)

                    Button("Editar perfil") { showingEditProfile = true }
                    if let user = currentUser, !user.isPro {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Text("Obtener Pro")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(Color(uiColor: .tertiaryLabel))
                            }
                        }
                    }
                }
                .glassListRow()

                // Escudos
                Section {
                    HStack {
                        Label("Escudos activos", systemImage: "shield.fill")
                        Spacer()
                        Text("\(totalShieldsCount)")
                            .foregroundStyle(Color.secondary)
                            .monospacedDigit()
                    }
                    if let user = currentUser {
                        let canAfford = user.totalXp >= GamificationEngine.shieldXPCost
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            showingShieldShop = true
                        } label: {
                            HStack {
                                Text("Comprar escudo")
                                Spacer()
                                Text("\(GamificationEngine.shieldXPCost) XP")
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        .disabled(!canAfford || habits.isEmpty)
                    }
                } header: {
                    Text("Protección")
                } footer: {
                    Text("Un escudo salva tu racha si olvidas un día.")
                }
                .glassListRow()

                // Logros
                Section("Logros") {
                    Button {
                        showingAllAchievements = true
                    } label: {
                        HStack {
                            Label("Insignias", systemImage: "trophy.fill")
                                .foregroundStyle(Color.primary)
                            Spacer()
                            Text("\(unlockedCount) de \(achievements.count)")
                                .foregroundStyle(Color.secondary)
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                        }
                    }
                }
                .glassListRow()

                // Aspecto
                Section("Aspecto") {
                    Picker(selection: $appThemeMode) {
                        ForEach(AppThemeMode.allCases) { mode in
                            Text(mode.displayName).tag(mode.rawValue)
                        }
                    } label: {
                        Label("Apariencia", systemImage: "circle.lefthalf.filled")
                    }

                    Picker(selection: Binding(
                        get: { selectedGlobalTheme },
                        set: { newValue in
                            let theme = GlobalTheme(rawValue: newValue) ?? .original
                            let isPro = currentUser?.isPro ?? false
                            if theme.isPremium && !isPro {
                                showingPaywall = true
                            } else {
                                selectedGlobalTheme = newValue
                            }
                        }
                    )) {
                        ForEach(GlobalTheme.allCases) { theme in
                            Text(theme.rawValue + (theme.isPremium ? " · Pro" : "")).tag(theme.rawValue)
                        }
                    } label: {
                        Label("Tema de color", systemImage: "paintpalette")
                    }

                    Picker(selection: Binding(
                        get: { currentAppIcon },
                        set: { newValue in
                            let isPro = currentUser?.isPro ?? false
                            if newValue != "default" && !isPro {
                                showingPaywall = true
                            } else {
                                changeAppIcon(to: newValue)
                            }
                        }
                    )) {
                        Text("Original").tag("default")
                        Text("Cyberpunk · Pro").tag("cyberpunk")
                        Text("Minimal · Pro").tag("minimal")
                        Text("Sunset · Pro").tag("sunset")
                    } label: {
                        Label("Icono de la app", systemImage: "app")
                    }
                }
                .glassListRow()

                // Ajustes
                Section("Ajustes") {
                    HStack {
                        Label("Zona horaria", systemImage: "globe")
                        Spacer()
                        Text(TimeZone.current.identifier)
                            .foregroundStyle(Color.secondary)
                    }
                    Button(role: .destructive) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation { currentUserId = "" }
                    } label: {
                        Text("Cerrar sesión")
                    }
                }
                .glassListRow()
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background { AuroraBackground() }
            .tint(Color.habPrimary)
            .navigationTitle("Perfil")
            .sheet(isPresented: $showingEditProfile) {
                if let user = currentUser {
                    EditProfileSheet(user: user)
                }
            }
            .sheet(isPresented: $showingAvatarPicker) {
                if let user = currentUser {
                    AvatarPickerSheet(user: user)
                }
            }
            .sheet(isPresented: $showingShieldShop) {
                if let user = currentUser {
                    ShieldShopSheet(user: user, habits: habits)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAllAchievements) {
                AchievementsDetailSheet(
                    achievements: achievements,
                    selectedCategory: $selectedCategory,
                    filteredAchievements: filteredAchievements,
                    unlockedCount: unlockedCount
                )
            }
            .onAppear {
                currentAppIcon = UIApplication.shared.alternateIconName ?? "default"
            }
        }
    }
    
    // MARK: - Helper Icono Alternativo
    
    private func changeAppIcon(to iconName: String) {
        let iconToSet = iconName == "default" ? nil : iconName
        UIApplication.shared.setAlternateIconName(iconToSet) { error in
            if let error = error {
                print("Error al cambiar el icono alternativo: \(error)")
            } else {
                currentAppIcon = iconName
                print("Icono de la app cambiado exitosamente a: \(iconName)")
            }
        }
    }
}

// ── Vista de Edición de Perfil ──
struct EditProfileSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let user: User
    
    @State private var name: String
    @State private var email: String
    
    init(user: User) {
        self.user = user
        _name = State(initialValue: user.name ?? "")
        _email = State(initialValue: user.email)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Información Personal")) {
                    TextField("Nombre", text: $name)
                    TextField("Correo Electrónico", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                .glassListRow()
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        user.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        user.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
                        try? modelContext.save()
                        Task {
                            try? await SupabaseService.shared.syncUser(user)
                        }
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// ── Tarjeta de Logro ──
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: achievement.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(achievement.isUnlocked ? Color.white : Color(uiColor: .tertiaryLabel))
                .frame(width: 44, height: 44)
                .background(
                    achievement.isUnlocked ? achievement.color : Color.primary.opacity(0.06),
                    in: RoundedRectangle(cornerRadius: 11, style: .continuous)
                )
                .accessibilityHidden(true)
            
            VStack(spacing: 2) {
                Text(achievement.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(achievement.isUnlocked ? Color.primary : Color.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2, reservesSpace: true)
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .glassCard(Radius.lg)
        .accessibilityElement(children: .combine)
        .accessibilityValue(achievement.isUnlocked ? "Desbloqueado" : "Bloqueado")
    }
}

// ── Modal de Detalle de Logros ──
struct AchievementsDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let achievements: [Achievement]
    @Binding var selectedCategory: AchievementCategory
    let filteredAchievements: [Achievement]
    let unlockedCount: Int
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    Picker("Categoría", selection: $selectedCategory.animation(.snappy)) {
                        ForEach(AchievementCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("\(unlockedCount) de \(achievements.count) desbloqueadas")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                }
                .padding(Spacing.lg)
            }
            .background { AuroraBackground() }
            .navigationTitle("Logros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Previsualización
#Preview {
    ProfileView()
        .modelContainer(for: [Habit.self, User.self], inMemory: true)
}
