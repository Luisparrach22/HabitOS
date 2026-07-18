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
    
    // Formulario State
    @State private var name: String = ""
    @State private var habitDescription: String = ""
    @State private var selectedIcon: String = "heart"
    @State private var selectedColorHex: String = habitColors[0].value
    @State private var selectedFrequency: Frequency = .daily
    @State private var trigger: String = ""
    
    // Custom Days State (para frecuencia CUSTOM)
    @State private var customDays: [String] = ["L", "M", "X"]
    private let weekDays = ["L", "M", "X", "J", "V", "S", "D"]
    
    // Modales State
    @State private var showingIconPicker = false
    
    // Convertir el string Hex a Color de SwiftUI de forma reactiva
    private var themeColor: Color {
        Color(hex: selectedColorHex)
    }
    
    // Fila rápida de iconos (los primeros 4 de default + el seleccionado actualmente)
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
                        .font(.habBody)
                    
                    TextField("Descripción: ¿Por qué es importante?", text: $habitDescription, axis: .vertical)
                        .font(.habBody)
                        .lineLimit(2...4)
                } header: {
                    Text("Detalles del Hábito")
                        .font(.habCaption)
                }
                .listRowBackground(Color.habCard)
                
                // ── SECCIÓN 2: ICONO Y COLOR ──
                Section {
                    // Fila rápida de iconos
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("ICONO")
                            .font(.habCaption)
                            .foregroundStyle(Color.habTextSecondary)
                        
                        HStack(spacing: Spacing.md) {
                            ForEach(quickIcons, id: \.self) { iconName in
                                let isActive = selectedIcon == iconName
                                Button {
                                    selectedIcon = iconName
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: Radius.md)
                                            .fill(isActive ? themeColor : Color.habCardMuted)
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
                                showingIconPicker = true
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: Radius.md)
                                        .strokeBorder(Color.habBorder, lineWidth: 2)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(Color.habAccentDeep)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, Spacing.xs)
                    
                    // Fila de Colores
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("COLOR")
                            .font(.habCaption)
                            .foregroundStyle(Color.habTextSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.md) {
                                ForEach(habitColors) { hColor in
                                    let isActive = selectedColorHex == hColor.value
                                    Button {
                                        selectedColorHex = hColor.value
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(hColor.color)
                                                .frame(width: 32, height: 32)
                                            
                                            if isActive {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 12, weight: .bold))
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
                }
                .listRowBackground(Color.habCard)
                
                // ── SECCIÓN 3: FRECUENCIA Y DISPARADOR ──
                Section {
                    // Selector de frecuencia
                    Picker("Frecuencia", selection: $selectedFrequency) {
                        Text("Diario").tag(Frequency.daily)
                        Text("Semanal").tag(Frequency.weekly)
                        Text("Pers.").tag(Frequency.custom)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, Spacing.xs)
                    
                    // Si la frecuencia es personalizada (Custom), muestra días de la semana
                    if selectedFrequency == .custom {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Días de la semana:")
                                .font(.habSubhead)
                                .foregroundStyle(Color.habTextSecondary)
                            
                            HStack(spacing: Spacing.xs) {
                                Spacer()
                                ForEach(weekDays, id: \.self) { day in
                                    let isSelected = customDays.contains(day)
                                    Button {
                                        if isSelected {
                                            customDays.removeAll(where: { $0 == day })
                                        } else {
                                            customDays.append(day)
                                        }
                                    } label: {
                                        Text(day)
                                            .font(.habCaption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(isSelected ? Color.white : Color.habTextPrimary)
                                            .frame(width: 36, height: 36)
                                            .background(
                                                Circle()
                                                    .fill(isSelected ? themeColor : Color.habCardMuted)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                                Spacer()
                            }
                        }
                        .padding(.vertical, Spacing.xs)
                    }
                    
                    // Habit Stack / Disparador
                    TextField("Disparador: Ej. Al terminar el café", text: $trigger)
                        .font(.habBody)
                } header: {
                    Text("Planificación e Hilado")
                        .font(.habCaption)
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
                    .font(.habBody)
                    .foregroundStyle(Color.habDanger)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Crear") {
                        saveHabit()
                    }
                    .font(.habHeadline)
                    .foregroundStyle(name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.habTextMuted : Color.habPrimary)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            // Lanzador del Selector de Iconos
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
        
        // Si es personalizado, hilamos los días en el trigger
        if selectedFrequency == .custom {
            let daysStr = customDays.joined(separator: ", ")
            finalTrigger = finalTrigger.isEmpty ? "Días: \(daysStr)" : "\(finalTrigger) (Días: \(daysStr))"
        }
        
        // Creamos la instancia de Hábito
        let newHabit = Habit(
            userId: "temp-user-id", // Por ahora mock, se enlazará luego
            name: trimmedName,
            habitDescription: trimmedDesc.isEmpty ? nil : trimmedDesc,
            trigger: finalTrigger.isEmpty ? nil : finalTrigger,
            frequency: selectedFrequency,
            color: selectedColorHex,
            icon: selectedIcon
        )
        
        // Insertamos en el contexto de SwiftData
        modelContext.insert(newHabit)
        
        // Intentamos guardar físicamente
        do {
            try modelContext.save()
            dismiss() // Cierra el formulario modal
        } catch {
            print("Error al guardar hábito en SwiftData: \(error)")
        }
    }
}

// MARK: - Previsualización

#Preview {
    CreateHabitView()
}
