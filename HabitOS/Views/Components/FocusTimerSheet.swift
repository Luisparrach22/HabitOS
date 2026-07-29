// ──────────────────────────────────────────────
// FocusTimerSheet.swift — Modo Enfoque / Pomodoro
// ──────────────────────────────────────────────
// Permite al usuario realizar sesiones de trabajo/estudio/meditación
// vinculadas a un hábito, ofreciendo temporizadores, sonidos de ambiente,
// retroalimentación háptica y bonificación de XP al finalizar.

import SwiftUI
import SwiftData
import AudioToolbox
import Combine

struct FocusTimerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let habit: Habit
    let isPro: Bool
    
    // Duraciones posibles (minutos)
    private let freeDurations = [5, 15]
    private let proDurations = [5, 15, 25, 45, 60]
    
    @State private var selectedMinutes: Int = 15
    @State private var timeRemaining: Int = 15 * 60
    @State private var timerRunning: Bool = false
    @State private var isCompleted: Bool = false
    @State private var selectedSound: String = "Ninguno"
    @State private var showingPaywall: Bool = false
    
    private let ambientSounds = ["Ninguno", "🌧️ Lofi Lluvia", "🌲 Bosque Profundo", "🌊 Olas de Mar"]
    
    // Timer de SwiftUI
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var progress: Double {
        let total = Double(selectedMinutes * 60)
        guard total > 0 else { return 0 }
        return Double(total - Double(timeRemaining)) / total
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#0B0E14")
                .ignoresSafeArea()
            
            // Glows de fondo
            VStack {
                Circle()
                    .fill(habit.swiftUIColor.opacity(0.18))
                    .frame(width: 300, height: 300)
                    .blur(radius: 70)
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Modo Enfoque")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                        Text(habit.name)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Anillo de Enfoque Principal
                ZStack {
                    // Pista de fondo
                    Circle()
                        .stroke(.white.opacity(0.08), lineWidth: 18)
                        .frame(width: 240, height: 240)
                    
                    // Anillo de progreso animado
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [habit.swiftUIColor, Color(hex: "#00F5D4")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 18, lineCap: .round)
                        )
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: progress)
                        .shadow(color: habit.swiftUIColor.opacity(0.4), radius: 12)
                    
                    // Tiempo formateado
                    VStack(spacing: 6) {
                        if isCompleted {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 54))
                                .foregroundStyle(Color(hex: "#00F5D4"))
                                .transition(.scale)
                            Text("¡Completado!")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                            Text("+50 XP Bonificación")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(hex: "#F5A623"))
                        } else {
                            Text(formatTime(timeRemaining))
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                            
                            Text(timerRunning ? "En proceso..." : "Listo para enfocar")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
                
                Spacer()
                
                // Selección de Duración (sólo disponible si no está en marcha)
                if !timerRunning && !isCompleted {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Duración de la sesión")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.sm) {
                                ForEach(proDurations, id: \.self) { mins in
                                    let isProOnly = !freeDurations.contains(mins)
                                    Button {
                                        if isProOnly && !isPro {
                                            showingPaywall = true
                                        } else {
                                            selectedMinutes = mins
                                            timeRemaining = mins * 60
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text("\(mins) min")
                                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                            if isProOnly {
                                                Image(systemName: "crown.fill")
                                                    .font(.caption2)
                                                    .foregroundStyle(Color(hex: "#F5A623"))
                                            }
                                        }
                                        .foregroundStyle(selectedMinutes == mins ? .white : .white.opacity(0.6))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: Radius.lg)
                                                .fill(selectedMinutes == mins ? habit.swiftUIColor : Color.white.opacity(0.06))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                
                // Selector de Sonidos Ambientales (Pro Feature)
                if !isCompleted {
                    HStack {
                        Image(systemName: "headphones")
                            .foregroundStyle(Color(hex: "#00F5D4"))
                        Text("Ambiente:")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Picker("Ambiente", selection: $selectedSound) {
                            ForEach(ambientSounds, id: \.self) { sound in
                                Text(sound).tag(sound)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color(hex: "#00F5D4"))
                        .onChange(of: selectedSound) { _, newValue in
                            if newValue != "Ninguno" && !isPro {
                                showingPaywall = true
                                selectedSound = "Ninguno"
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: Radius.lg).fill(Color.white.opacity(0.05)))
                    .padding(.horizontal, 24)
                }
                
                // Botón Principal de Acción
                Button {
                    if isCompleted {
                        dismiss()
                    } else {
                        toggleTimer()
                    }
                } label: {
                    HStack {
                        Image(systemName: isCompleted ? "checkmark" : (timerRunning ? "pause.fill" : "play.fill"))
                        Text(isCompleted ? "Finalizar" : (timerRunning ? "Pausar Enfoque" : "Iniciar Enfoque"))
                            .font(.system(.body, design: .rounded, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: isCompleted ? [Color(hex: "#2DD4A8"), Color(hex: "#00F5D4")] : [habit.swiftUIColor, habit.swiftUIColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(Radius.xl)
                    .shadow(color: habit.swiftUIColor.opacity(0.4), radius: 10, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onReceive(timer) { _ in
            guard timerRunning && timeRemaining > 0 else { return }
            timeRemaining -= 1
            if timeRemaining == 0 {
                finishSession()
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
    
    private func toggleTimer() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        timerRunning.toggle()
    }
    
    private func finishSession() {
        timerRunning = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            isCompleted = true
        }
        
        // Feedback háptico de éxito
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1054)
        
        // 1. Marcar hábito como completado si aún no lo estaba
        if !habit.isCompletedToday {
            let log = HabitLog(habitId: habit.id)
            log.habit = habit
            modelContext.insert(log)
            habit.currentStreak += 1
            if habit.currentStreak > habit.maxStreak {
                habit.maxStreak = habit.currentStreak
            }
        }
        
        // 2. Otorgar +50 XP de bonificación de enfoque al usuario
        if let user = habit.user {
            let xpMultiplier = isPro ? 2 : 1
            let gainedXp = 50 * xpMultiplier
            GamificationEngine.addBonusXP(amount: gainedXp, to: user, context: modelContext)
        }
        
        try? modelContext.save()
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
