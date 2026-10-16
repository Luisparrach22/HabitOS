// ──────────────────────────────────────────────
// OnboardingView.swift — Pantallas de Bienvenido e Inicio
// ──────────────────────────────────────────────
// Carrusel interactivo de primer inicio que presenta las funciones clave,
// permite configurar el nombre del usuario y seleccionar hábitos semilla.

import SwiftUI
import SwiftData

struct SeedHabit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    let description: String
    var isSelected: Bool
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentStep = 0
    @State private var userName: String = ""
    
    // Hábitos Semilla Recomendados
    @State private var seedHabits: [SeedHabit] = [
        SeedHabit(name: "Beber 2L de Agua", icon: "drop.fill", color: "#018ABE", description: "Hidrátate para mantener la energía", isSelected: true),
        SeedHabit(name: "Leer 15 Minutos", icon: "book.fill", color: "#8B5CF6", description: "Nutre tu mente a diario", isSelected: true),
        SeedHabit(name: "Hacer Ejercicio", icon: "dumbbell.fill", color: "#EF4444", description: "Muévete y activa tu cuerpo", isSelected: true),
        SeedHabit(name: "Meditación", icon: "brain.head.profile", color: "#2DD4A8", description: "5 minutos de paz mental", isSelected: false)
    ]
    
    var body: some View {
        ZStack {
            AuroraBackground()
            
            VStack(spacing: 0) {
                // Barra de Progreso Superior
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Capsule()
                            .fill(index <= currentStep ? Color.habPrimary : Color.primary.opacity(0.1))
                            .frame(height: 4)
                            .animation(.smooth(duration: 0.3), value: currentStep)
                    }
                }
                .padding(.horizontal, Spacing.xl2)
                .padding(.top, Spacing.lg)
                
                Spacer()
                
                // Contenido del Carrusel
                TabView(selection: $currentStep) {
                    // PASO 0: Rachas
                    OnboardingSlide(
                        icon: "flame.fill",
                        color: .habWarning,
                        title: "Construye rachas",
                        subtitle: "Completa tus objetivos diarios y observa cómo tu disciplina crece día tras día."
                    )
                    .tag(0)
                    
                    // PASO 1: Escudos
                    OnboardingSlide(
                        icon: "shield.fill",
                        color: .habPrimary,
                        title: "Protege tu progreso",
                        subtitle: "¿Un día difícil? Los escudos evitan que pierdas tu racha al fallar una jornada."
                    )
                    .tag(1)
                    
                    // PASO 2: Gamificación & XP
                    OnboardingSlide(
                        icon: "star.fill",
                        color: .habWarning,
                        title: "Sube de nivel",
                        subtitle: "Cada hábito completado otorga puntos de experiencia para subir de nivel y desbloquear insignias."
                    )
                    .tag(2)
                    
                    // PASO 3: Personalización y Hábitos Semilla
                    personalizationStepView
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer()
                
                // Botón de Acción Principal
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    if currentStep < 3 {
                        withAnimation(.smooth(duration: 0.35)) {
                            currentStep += 1
                        }
                    } else {
                        finishOnboarding()
                    }
                } label: {
                    Text(currentStep == 3 ? "Comenzar" : "Siguiente")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.glassProminent)
                .tint(Color.habPrimary)
                .disabled(currentStep == 3 && !nameIsValid)
                .padding(.horizontal, Spacing.xl2)
                .padding(.bottom, Spacing.xl)
            }
        }
    }
    
    private var nameIsValid: Bool {
        !userName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // Vista del paso final de personalización
    private var personalizationStepView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.xl) {
                VStack(spacing: Spacing.xs) {
                    Text("Personaliza tu sistema")
                        .font(.title2.weight(.bold))
                    
                    Text("Escribe tu nombre y elige tus primeros hábitos.")
                        .font(.subheadline)
                        .foregroundStyle(Color.habTextMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Spacing.md)
                
                // Campo de Texto de Nombre
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Tu nombre")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .padding(.leading, Spacing.xs)
                    
                    TextField("Nombre", text: $userName)
                        .font(.body)
                        .textContentType(.givenName)
                        .padding(Spacing.lg)
                        .glassCard(Radius.lg)
                }
                
                // Selección de Hábitos Semilla
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Hábitos iniciales")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .padding(.leading, Spacing.xs)
                    
                    VStack(spacing: 0) {
                        ForEach($seedHabits) { $habit in
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                habit.isSelected.toggle()
                            } label: {
                                HStack(spacing: Spacing.md) {
                                    Image(systemName: habit.icon)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .frame(width: 32, height: 32)
                                        .background(Color(hex: habit.color), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(habit.name)
                                            .font(.body)
                                            .foregroundStyle(Color.primary)
                                        Text(habit.description)
                                            .font(.footnote)
                                            .foregroundStyle(Color.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: habit.isSelected ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundStyle(habit.isSelected ? Color.habPrimary : Color(uiColor: .tertiaryLabel))
                                }
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, Spacing.md)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(habit.isSelected ? .isSelected : [])

                            if habit.id != seedHabits.last?.id {
                                Divider().padding(.leading, 60)
                            }
                        }
                    }
                    .glassCard(Radius.lg)
                }
            }
            .padding(.horizontal, Spacing.xl2)
        }
    }
    
    // Finaliza el onboarding y guarda datos iniciales
    private func finishOnboarding() {
        let name = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Evitar duplicar el usuario si ya existe alguno
        let userFetch = FetchDescriptor<User>()
        let user: User
        if let existingUser = (try? modelContext.fetch(userFetch))?.first {
            user = existingUser
        } else {
            let finalName = name.isEmpty ? "Guerrero" : name
            let newUser = User(
                email: "usuario@habitos.app",
                name: finalName,
                passwordHash: "local",
                avatarUrl: "owl:0",
                totalXp: 0,
                level: 1,
                timezone: TimeZone.current.identifier
            )
            modelContext.insert(newUser)
            user = newUser
        }
        
        // Evitar insertar hábitos semilla si ya existen hábitos en la base de datos
        let habitFetch = FetchDescriptor<Habit>()
        let existingHabitsCount = (try? modelContext.fetchCount(habitFetch)) ?? 0
        var createdHabits: [Habit] = []
        
        if existingHabitsCount == 0 {
            for seed in seedHabits where seed.isSelected {
                let habit = Habit(
                    userId: user.id,
                    name: seed.name,
                    habitDescription: seed.description,
                    frequency: .daily,
                    color: seed.color,
                    icon: seed.icon
                )
                modelContext.insert(habit)
                createdHabits.append(habit)
            }
        }
        
        try? modelContext.save()
        
        Task {
            try? await SupabaseService.shared.syncUser(user)
            for h in createdHabits {
                try? await SupabaseService.shared.syncHabit(h)
            }
        }
        
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Slide
struct OnboardingSlide: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: Spacing.xl2) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 96, height: 96)
                .glassEffect(.regular.tint(color.opacity(0.75)), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .accessibilityHidden(true)
            
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, Spacing.xl2)
    }
}
