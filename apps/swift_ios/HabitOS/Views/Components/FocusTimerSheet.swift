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
    
    private let ambientSounds = ["Ninguno", "Lofi lluvia", "Bosque profundo", "Olas de mar"]
    
    // Timer de SwiftUI
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var progress: Double {
        let total = Double(selectedMinutes * 60)
        guard total > 0 else { return 0 }
        return Double(total - Double(timeRemaining)) / total
    }
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Modo enfoque")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    Text(habit.name)
                        .font(.title2.weight(.semibold))
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.secondary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Cerrar")
            }
            .padding(.horizontal, Spacing.xl2)
            .padding(.top, Spacing.sm)

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(habit.swiftUIColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: progress)

                VStack(spacing: 6) {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.habSuccess)
                            .transition(.scale)
                        Text("Completado")
                            .font(.title3.weight(.semibold))
                        Text("+50 XP")
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                    } else {
                        Text(formatTime(timeRemaining))
                            .font(.system(size: 52, weight: .light))
                            .monospacedDigit()
                        Text(timerRunning ? "En curso" : "Listo")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .frame(width: 250, height: 250)

            Spacer()

            if !timerRunning && !isCompleted {
                Picker("Duración", selection: Binding(
                    get: { selectedMinutes },
                    set: { mins in
                        if !freeDurations.contains(mins) && !isPro {
                            showingPaywall = true
                        } else {
                            selectedMinutes = mins
                            timeRemaining = mins * 60
                        }
                    }
                )) {
                    ForEach(proDurations, id: \.self) { mins in
                        Text("\(mins) min").tag(mins)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.xl2)
            }

            if !isCompleted {
                HStack {
                    Label("Ambiente", systemImage: "headphones")
                    Spacer()
                    Picker("Ambiente", selection: $selectedSound) {
                        ForEach(ambientSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedSound) { _, newValue in
                        if newValue != "Ninguno" && !isPro {
                            showingPaywall = true
                            selectedSound = "Ninguno"
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .glassCard(Radius.lg)
                .padding(.horizontal, Spacing.xl2)
            }

            Button {
                if isCompleted {
                    dismiss()
                } else {
                    toggleTimer()
                }
            } label: {
                Label(
                    isCompleted ? "Finalizar" : (timerRunning ? "Pausar" : "Iniciar"),
                    systemImage: isCompleted ? "checkmark" : (timerRunning ? "pause.fill" : "play.fill")
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .buttonStyle(.glassProminent)
            .tint(habit.swiftUIColor)
            .padding(.horizontal, Spacing.xl2)
            .padding(.bottom, Spacing.xl2)
        }
        .background { AuroraBackground() }
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
        var newlyCreatedLog: HabitLog? = nil
        if !habit.isCompletedToday {
            let log = HabitLog(habitId: habit.id)
            log.habit = habit
            modelContext.insert(log)
            if habit.logs == nil { habit.logs = [] }
            habit.logs?.append(log)
            habit.currentStreak += 1
            if habit.currentStreak > habit.maxStreak {
                habit.maxStreak = habit.currentStreak
            }
            newlyCreatedLog = log
        }
        
        // 2. Otorgar +50 XP de bonificación de enfoque al usuario
        if let user = habit.user {
            let xpMultiplier = isPro ? 2 : 1
            let gainedXp = 50 * xpMultiplier
            GamificationEngine.addBonusXP(amount: gainedXp, to: user, context: modelContext)
        }
        
        try? modelContext.save()
        
        Task {
            if let log = newlyCreatedLog {
                try? await SupabaseService.shared.syncHabitLog(log)
            }
            try? await SupabaseService.shared.syncHabit(habit)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
