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
            ZStack {
                Color.habBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        
                        // 1. Tarjeta Principal de Perfil y Nivel
                        VStack(spacing: Spacing.md) {
                            // Avatar interactivo con Badge de Nivel
                            ZStack(alignment: .bottomTrailing) {
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    showingAvatarPicker = true
                                } label: {
                                    AvatarView(avatarString: currentUser?.avatarUrl, size: 80)
                                }
                                .buttonStyle(.plain)
                                
                                Text("Nv. \(currentUser?.level ?? 1)")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.habWarning)
                                    .cornerRadius(Radius.full)
                            }
                            
                            VStack(spacing: 2) {
                                HStack(spacing: 8) {
                                    Text(currentUser?.name ?? "Desarrollador HabitOS")
                                        .font(.system(.title3, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.primary)
                                    
                                    if currentUser?.isPro ?? false {
                                        Text("PRO")
                                            .font(.system(size: 10, weight: .black, design: .rounded))
                                            .foregroundStyle(Color.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(
                                                LinearGradient(
                                                    colors: [Color(hex: "#8B5CF6"), Color(hex: "#EC4899")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .cornerRadius(6)
                                    } else {
                                        Text("GRATIS")
                                            .font(.system(size: 10, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.secondary)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.primary.opacity(0.06))
                                            .cornerRadius(6)
                                    }
                                }
                                
                                Text(currentUser?.email ?? "usuario@habitos.app")
                                    .font(.footnote)
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            if let user = currentUser {
                                HStack(spacing: 12) {
                                    Button {
                                        showingEditProfile = true
                                    } label: {
                                        Text("Editar Perfil")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.habPrimary)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color.habPrimary.opacity(0.1))
                                            .cornerRadius(Radius.full)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if !user.isPro {
                                        Button {
                                            showingPaywall = true
                                        } label: {
                                            Text("Obtener Pro ✨")
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(
                                                    LinearGradient(
                                                        colors: [Color(hex: "#8B5CF6"), Color(hex: "#EC4899")],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(Radius.full)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            
                            // Barra de Progreso a Siguiente Nivel
                            let currentXP = GamificationEngine.xpInCurrentLevel(totalXP: currentUser?.totalXp ?? 0)
                            let xpLimit = GamificationEngine.xpPerLevel
                            let fraction = CGFloat(GamificationEngine.levelProgressFraction(totalXP: currentUser?.totalXp ?? 0))
                            
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                HStack {
                                    Text("Progreso de Nivel")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.secondary)
                                    Spacer()
                                    Text("\(currentXP) / \(xpLimit) XP")
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundStyle(Color.secondary)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.primary.opacity(0.04))
                                            .frame(height: 8)
                                        
                                        Capsule()
                                            .fill(Color.habPrimary)
                                            .frame(width: geometry.size.width * fraction, height: 8)
                                    }
                                }
                                .frame(height: 8)
                            }
                            .padding(.top, Spacing.sm)
                        }
                        .padding(18)
                        .background(Color.habCard)
                        .cornerRadius(Radius.xl2)
                        .shadow(color: Color.black.opacity(0.01), radius: 6, x: 0, y: 3)
                        
                        // 2. Inventario de Escudos
                        HStack(spacing: Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(Color.habPrimary.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.habPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Escudos de Protección")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.primary)
                                Text("Tienes \(totalShieldsCount) escudos activos en tus hábitos.")
                                    .font(.footnote)
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            Spacer()
                            
                            if let user = currentUser {
                                let canAfford = user.totalXp >= GamificationEngine.shieldXPCost
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    showingShieldShop = true
                                } label: {
                                    Text(canAfford ? "Comprar ⚡" : "Comprar")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(canAfford ? Color.white : Color.secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(canAfford ? Color.habPrimary : Color.primary.opacity(0.04))
                                        .cornerRadius(Radius.sm)
                                }
                                .buttonStyle(.plain)
                                .disabled(!canAfford || habits.isEmpty)
                            }
                        }
                        .padding(14)
                        .background(Color.habCard)
                        .cornerRadius(Radius.lg)
                        .shadow(color: Color.black.opacity(0.01), radius: 4, x: 0, y: 2)
                        
                        // 3. Resumen de Insignias y Logros
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundStyle(Color.habWarning)
                                    .font(.subheadline)
                                Text("Insignias y Logros")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.primary)
                                Spacer()
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    showingAllAchievements = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("Ver todos (\(unlockedCount))")
                                            .font(.system(.footnote, design: .rounded).bold())
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                    .foregroundStyle(Color.habPrimary)
                                }
                            }
                            .padding(.horizontal, Spacing.xs)
                            
                            // Vista previa compacta (3 insignias horizontales)
                            HStack(spacing: Spacing.sm) {
                                ForEach(achievements.prefix(3)) { achievement in
                                    AchievementPreviewCell(achievement: achievement)
                                }
                            }
                            .padding(.top, 4)
                        }
                        
                        // 4. Aspecto y Personalización
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("ASPECTO Y PERSONALIZACIÓN")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .padding(.horizontal, Spacing.xs)
                            
                            VStack(spacing: 0) {
                                // 1. Tema Claro/Oscuro/Sistema
                                HStack {
                                    Label("Tema de la App", systemImage: "paintbrush.fill")
                                        .font(.body)
                                        .foregroundStyle(Color.primary)
                                    Spacer()
                                    Picker("", selection: $appThemeMode) {
                                        ForEach(AppThemeMode.allCases) { mode in
                                            Text(mode.displayName).tag(mode.rawValue)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(Color.habPrimary)
                                }
                                .padding(14)
                                
                                Divider()
                                    .opacity(0.5)
                                
                                // 2. Temas de color globales
                                HStack {
                                    Label("Tema de Color", systemImage: "paintpalette.fill")
                                        .font(.body)
                                        .foregroundStyle(Color.primary)
                                    Spacer()
                                    Picker("", selection: Binding(
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
                                            Text(theme.rawValue + (theme.isPremium ? " 👑" : "")).tag(theme.rawValue)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(Color.habPrimary)
                                }
                                .padding(14)
                                
                                Divider()
                                    .opacity(0.5)
                                
                                // 3. Icono alternativo
                                HStack {
                                    Label("Icono de la App", systemImage: "app.dashed")
                                        .font(.body)
                                        .foregroundStyle(Color.primary)
                                    Spacer()
                                    Picker("", selection: Binding(
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
                                        Text("Cyberpunk 👑").tag("cyberpunk")
                                        Text("Minimal 👑").tag("minimal")
                                        Text("Sunset 👑").tag("sunset")
                                    }
                                    .pickerStyle(.menu)
                                    .tint(Color.habPrimary)
                                }
                                .padding(14)
                            }
                            .background(Color.habCard)
                            .cornerRadius(Radius.lg)
                        }
                        
                        // 5. Ajustes de la App
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("AJUSTES")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .padding(.horizontal, Spacing.xs)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Label("Zona Horaria", systemImage: "globe")
                                        .font(.body)
                                        .foregroundStyle(Color.primary)
                                    Spacer()
                                    Text(TimeZone.current.identifier)
                                        .font(.footnote)
                                        .foregroundStyle(Color.secondary)
                                }
                                .padding(14)
                                
                                Divider()
                                    .opacity(0.5)
                                
                                // Cerrar Sesión
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    withAnimation {
                                        currentUserId = ""
                                    }
                                } label: {
                                    HStack {
                                        Label("Cerrar Sesión", systemImage: "arrow.right.square")
                                            .font(.body)
                                            .foregroundStyle(Color.habDanger)
                                        Spacer()
                                    }
                                    .padding(14)
                                }
                                .buttonStyle(.plain)
                            }
                            .background(Color.habCard)
                            .cornerRadius(Radius.lg)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl3)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            }
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

// ── Tarjeta de Logro Premium ──
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack(alignment: .topTrailing) {
                // Icono del logro con su color temático
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? achievement.color.opacity(0.1) : Color.primary.opacity(0.04))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(achievement.isUnlocked ? achievement.color : Color.secondary.opacity(0.5))
                }
                
                // Indicador de estado (candado o checkmark)
                if achievement.isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.habSuccess)
                        .background(Circle().fill(Color.white))
                        .offset(x: 2, y: -2)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.secondary.opacity(0.6))
                        .offset(x: 2, y: -2)
                }
            }
            .padding(.top, Spacing.xs)
            
            VStack(spacing: 2) {
                Text(achievement.title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(achievement.isUnlocked ? Color.primary : Color.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                Text(achievement.description)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 28, alignment: .top)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.habCard)
        .cornerRadius(Radius.md)
        .shadow(color: Color.black.opacity(0.01), radius: 3, x: 0, y: 1.5)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(achievement.isUnlocked ? achievement.color.opacity(0.15) : Color.primary.opacity(0.03), lineWidth: 1)
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.65)
    }
}

// ── Celda de Vista Previa de Logro ──
struct AchievementPreviewCell: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? achievement.color.opacity(0.12) : Color.primary.opacity(0.04))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(achievement.isUnlocked ? achievement.color : Color.secondary.opacity(0.4))
                }
                
                if achievement.isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.habSuccess)
                        .background(Circle().fill(Color.white))
                        .offset(x: 2, y: -2)
                }
            }
            
            Text(achievement.title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(achievement.isUnlocked ? Color.primary : Color.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(Color.habCard)
        .cornerRadius(Radius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(achievement.isUnlocked ? achievement.color.opacity(0.15) : Color.primary.opacity(0.03), lineWidth: 1)
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
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
            ZStack {
                Color.habBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        // 1. Cabecera e Indicador de Progreso
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            HStack {
                                Text("Tu Progreso de Logros")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.primary)
                                Spacer()
                                Text("\(unlockedCount) de \(achievements.count) completados")
                                    .font(.system(.footnote, design: .rounded).bold())
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            // Barra de Progreso de Logros
                            let fraction = CGFloat(unlockedCount) / CGFloat(achievements.count)
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.primary.opacity(0.04))
                                        .frame(height: 8)
                                    
                                    Capsule()
                                        .fill(Color.habWarning)
                                        .frame(width: geometry.size.width * fraction, height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding(.horizontal, Spacing.xs)
                        
                        // 2. Selector de Categoría (Chips Horizontales)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.sm) {
                                ForEach(AchievementCategory.allCases) { category in
                                    let isSelected = selectedCategory == category
                                    Button {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                            selectedCategory = category
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: category.iconName)
                                                .font(.system(size: 11))
                                            Text(category.rawValue)
                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(isSelected ? Color.habPrimary : Color.habCard)
                                        .foregroundStyle(isSelected ? Color.white : Color.secondary)
                                        .cornerRadius(Radius.full)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Radius.full)
                                                .stroke(isSelected ? Color.clear : Color.habBorderLight, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 2)
                        }
                        
                        // 3. Rejilla de Logros Filtrados
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filteredAchievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.top, Spacing.xs)
                    }
                    .padding()
                }
            }
            .navigationTitle("Insignias y Logros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded).bold())
                    .foregroundStyle(Color.habPrimary)
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
