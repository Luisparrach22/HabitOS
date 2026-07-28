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
            Color.habBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Barra de Progreso Superior
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Capsule()
                            .fill(index <= currentStep ? Color.habPrimary : Color.habPrimary.opacity(0.15))
                            .frame(height: 5)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
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
                        iconColors: [Color(hex: "#FF9F0A"), Color(hex: "#FF3B30")],
                        title: "Construye Rachas Indestructibles",
                        subtitle: "Completa tus objetivos diarios y observa cómo tu disciplina crece día tras día."
                    )
                    .tag(0)
                    
                    // PASO 1: Escudos
                    OnboardingSlide(
                        icon: "shield.fill",
                        iconColors: [Color(hex: "#00F5D4"), Color(hex: "#018ABE")],
                        title: "Protege tu Progreso con Escudos",
                        subtitle: "¿Un día difícil? Los escudos evitan que pierdas tu racha al fallar una jornada."
                    )
                    .tag(1)
                    
                    // PASO 2: Gamificación & XP
                    OnboardingSlide(
                        icon: "star.fill",
                        iconColors: [Color(hex: "#FFCC00"), Color(hex: "#FF9500")],
                        title: "Sube de Nivel y Gana XP",
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
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentStep += 1
                        }
                    } else {
                        finishOnboarding()
                    }
                } label: {
                    Text(currentStep == 3 ? "Comenzar mi Sistema ⚡" : "Siguiente")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.xl)
                                .fill(nameIsValid || currentStep < 3 ? Color.habPrimary : Color.habPrimary.opacity(0.4))
                        )
                        .shadow(color: Color.habPrimary.opacity(0.15), radius: 8, x: 0, y: 4)
                }
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
                    Text("¡Personaliza tu Sistema!")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.habTextPrimary)
                    
                    Text("Ingresa tu nombre y elige tus primeros hábitos")
                        .font(.subheadline)
                        .foregroundStyle(Color.habTextMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Spacing.md)
                
                // Campo de Texto de Nombre
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("¿CÓMO TE LLAMAMOS?")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.habTextSecondary)
                        .padding(.leading, Spacing.xs)
                    
                    TextField("Tu nombre (ej. Alex)", text: $userName)
                        .font(.body)
                        .padding(16)
                        .background(Color.habCard)
                        .cornerRadius(Radius.lg)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.lg)
                                .stroke(Color.habBorder, lineWidth: 1)
                        )
                }
                
                // Selección de Hábitos Semilla
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("HÁBITOS INICIALES RECOMENDADOS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.habTextSecondary)
                        .padding(.leading, Spacing.xs)
                    
                    VStack(spacing: Spacing.sm) {
                        ForEach($seedHabits) { $habit in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: habit.color).opacity(0.12))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: habit.icon)
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color(hex: habit.color))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(habit.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.habTextPrimary)
                                    Text(habit.description)
                                        .font(.caption)
                                        .foregroundStyle(Color.habTextMuted)
                                }
                                
                                Spacer()
                                
                                Image(systemName: habit.isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(habit.isSelected ? Color.habSuccess : Color.habTextMuted)
                                    .scaleEffect(habit.isSelected ? 1.1 : 1.0)
                                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: habit.isSelected)
                            }
                            .padding(14)
                            .background(Color.habCard)
                            .cornerRadius(Radius.lg)
                            .shadow(color: Color.black.opacity(0.01), radius: 4, x: 0, y: 2)
                            .onTapGesture {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                withAnimation {
                                    habit.isSelected.toggle()
                                }
                            }
                        }
                    }
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
            }
        }
        
        try? modelContext.save()
        
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Slide Reutilizable Premium
struct OnboardingSlide: View {
    let icon: String
    let iconColors: [Color]
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: Spacing.xl2) {
            ZStack {
                Circle()
                    .fill(iconColors[0].opacity(0.12))
                    .frame(width: 140, height: 140)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: iconColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: iconColors[0].opacity(0.3), radius: 15, x: 0, y: 8)
                
                Image(systemName: icon)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: Spacing.md) {
                Text(title)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.habTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.md)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(Color.habTextMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, Spacing.xl)
            }
        }
        .padding(.horizontal, Spacing.xl2)
    }
}
