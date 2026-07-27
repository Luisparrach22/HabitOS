// ──────────────────────────────────────────────
// CreateHabitView.swift — Formulario para Crear Hábito
// ──────────────────────────────────────────────
// Pantalla de formulario en SwiftUI que permite al
// usuario crear un hábito especificando nombre, descripción,
// icono, color, frecuencia y disparador, guardándolo en SwiftData.

import SwiftUI
import SwiftData

struct CreateHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var users: [User]
    
    // Formulario State
    @State private var name: String = ""
    @State private var habitDescription: String = ""
    @State private var selectedIcon: String = "heart"
    @State private var selectedColorHex: String = habitColors[0].value
    @State private var selectedFrequency: Frequency = .daily
    @State private var trigger: String = ""
    
    // Notifications State
    @State private var enableReminder: Bool = false
    @State private var reminderTime: Date = Date()
    
    // Custom Days State (para frecuencia CUSTOM)
    @State private var customDays: [String] = ["L", "M", "X"]
    private let weekDays = ["L", "M", "X", "J", "V", "S", "D"]
    
    // Modales State
    @State private var showingIconPicker = false
    
    // Convertir el string Hex a Color de SwiftUI de forma reactiva
    private var themeColor: Color {
        Color(hex: selectedColorHex)
    }
    
    // Fila rápida de iconos
    private var quickIcons: [String] {
        var list = defaultQuickIcons
        if !list.contains(selectedIcon) {
            list.insert(selectedIcon, at: 0)
        }
        return Array(list.prefix(5))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                // ── SECCIÓN 1: NOMBRE Y DESCRIPCIÓN ──
                Section {
                    TextField("Nombre: Ej. Beber agua", text: $name)
                        .font(.body)
                    
                    TextField("Descripción: ¿Por qué es importante?", text: $habitDescription, axis: .vertical)
                        .font(.body)
                        .lineLimit(2...4)
                } header: {
                    Text("DETALLES DEL HÁBITO")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
                .listRowBackground(Color.habCard)
                
                // ── SECCIÓN 2: ICONO Y COLOR ──
                Section {
                    // Selector rápido de Iconos
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("ICONO")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                        
                        HStack(spacing: Spacing.md) {
                            ForEach(quickIcons, id: \.self) { iconName in
                                let isActive = selectedIcon == iconName
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    selectedIcon = iconName
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: Radius.md)
                                            .fill(isActive ? themeColor : Color.habBackground)
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: iconName)
                                            .font(.system(size: 18))
                                            .foregroundStyle(isActive ? Color.white : themeColor)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Botón más iconos (+)
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                showingIconPicker = true
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: Radius.md)
                                        .strokeBorder(Color.habBorder, lineWidth: 1.5)
                                        .background(Color.habBackground.cornerRadius(Radius.md))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, Spacing.xs)
                    
                    // Selector de Colores
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("COLOR")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.md) {
                                ForEach(habitColors) { hColor in
                                    let isActive = selectedColorHex == hColor.value
                                    Button {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        selectedColorHex = hColor.value
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(hColor.color)
                                                .frame(width: 32, height: 32)
                                            
                                            if isActive {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundStyle(Color.white)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding(.vertical, Spacing.xs)
                } header: {
                    Text("PERSONALIZACIÓN VISUAL")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
                .listRowBackground(Color.habCard)
                
                // ── SECCIÓN 3: FRECUENCIA Y RECORDATORIO ──
                Section {
                    // Selector de frecuencia
                    Picker("Frecuencia", selection: $selectedFrequency) {
                        Text("Diario").tag(Frequency.daily)
                        Text("Semanal").tag(Frequency.weekly)
                        Text("Pers.").tag(Frequency.custom)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, Spacing.xs)
                    
                    // Frecuencia personalizada (días de la semana)
                    if selectedFrequency == .custom {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Días de la semana:")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            
                            HStack(spacing: Spacing.xs) {
                                Spacer()
                                ForEach(weekDays, id: \.self) { day in
                                    let isSelected = customDays.contains(day)
                                    Button {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        if isSelected {
                                            customDays.removeAll(where: { $0 == day })
                                        } else {
                                            customDays.append(day)
                                        }
                                    } label: {
                                        Text(day)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(isSelected ? Color.white : Color.primary)
                                            .frame(width: 36, height: 36)
                                            .background(
                                                Circle()
                                                    .fill(isSelected ? themeColor : Color.habBackground)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                                Spacer()
                            }
                        }
                        .padding(.vertical, Spacing.xs)
                    }
                    
                    // Toggle de Recordatorio Diario
                    Toggle(isOn: $enableReminder) {
                        Label("Recordatorio Diario", systemImage: "bell.fill")
                            .font(.body)
                    }
                    .tint(themeColor)
                    
                    if enableReminder {
                        DatePicker("Hora de notificación", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .font(.body)
                    }
                    
                    // Disparador
                    TextField("Disparador: Ej. Al terminar el café", text: $trigger)
                        .font(.body)
                } header: {
                    Text("PLANIFICACIÓN Y RECORDATORIOS")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
                .listRowBackground(Color.habCard)
            }
            .scrollContentBackground(.hidden)
            .background(Color.habBackground)
            .navigationTitle("Nuevo Hábito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .font(.body)
                    .foregroundStyle(Color.habDanger)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Crear") {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        saveHabit()
                    }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.secondary.opacity(0.4) : Color.habPrimary)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerSheet(selectedIcon: $selectedIcon, themeColor: themeColor)
            }
        }
    }
    
    // Lógica para guardar en SwiftData
    private func saveHabit() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let trimmedDesc = habitDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        var finalTrigger = trigger.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if selectedFrequency == .custom {
            let daysStr = customDays.joined(separator: ", ")
            finalTrigger = finalTrigger.isEmpty ? "Días: \(daysStr)" : "\(finalTrigger) (Días: \(daysStr))"
        }
        
        let ownerId = users.first?.id ?? "local_user_id"
        
        let newHabit = Habit(
            userId: ownerId,
            name: trimmedName,
            habitDescription: trimmedDesc.isEmpty ? nil : trimmedDesc,
            trigger: finalTrigger.isEmpty ? nil : finalTrigger,
            frequency: selectedFrequency,
            color: selectedColorHex,
            icon: selectedIcon
        )
        
        modelContext.insert(newHabit)
        
        do {
            try modelContext.save()
            
            if enableReminder {
                NotificationService.shared.requestAuthorization { granted in
                    if granted {
                        NotificationService.shared.scheduleReminder(for: newHabit, at: reminderTime)
                    }
                }
            }
            
            dismiss()
        } catch {
            print("Error al guardar hábito en SwiftData: \(error)")
        }
    }
}

// MARK: - Previsualización
#Preview {
    CreateHabitView()
}
