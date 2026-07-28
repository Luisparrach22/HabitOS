// ──────────────────────────────────────────────
// AvatarPickerSheet.swift — Vista de Personalización de Avatar
// ──────────────────────────────────────────────
// Permite al usuario elegir un personaje y un gradiente de fondo,
// mostrando una previsualización interactiva con animaciones fluidas.

import SwiftUI
import SwiftData

struct AvatarPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let user: User
    
    @State private var selectedAvatarID: String
    @State private var selectedGradientID: Int
    
    // Configuración de rejilla adaptativa
    private let avatarColumns = [
        GridItem(.adaptive(minimum: 64, maximum: 74), spacing: 12)
    ]
    private let gradientColumns = [
        GridItem(.adaptive(minimum: 44, maximum: 54), spacing: 12)
    ]
    
    init(user: User) {
        self.user = user
        let (option, bgGradient) = AvatarSystem.parseAvatar(user.avatarUrl)
        _selectedAvatarID = State(initialValue: option.id)
        _selectedGradientID = State(initialValue: bgGradient.id)
    }
    
    private var currentAvatarString: String {
        "\(selectedAvatarID):\(selectedGradientID)"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.habBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.xl) {
                        
                        // 1. Previsualización Grande del Avatar
                        VStack(spacing: Spacing.sm) {
                            AvatarView(avatarString: currentAvatarString, size: 110)
                                .scaleEffect(1.0)
                                // Animación de muelle al cambiar avatar o color
                                .animation(.spring(response: 0.35, dampingFraction: 0.6), value: selectedAvatarID)
                                .animation(.spring(response: 0.35, dampingFraction: 0.6), value: selectedGradientID)
                                .padding(.top, Spacing.md)
                            
                            let (selectedOption, _) = AvatarSystem.parseAvatar(currentAvatarString)
                            Text(selectedOption.name)
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        
                        // 2. Selector de Personajes (Mascotas)
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("SELECCIONA TU MASCOTA")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .padding(.horizontal, Spacing.xs)
                            
                            LazyVGrid(columns: avatarColumns, spacing: 12) {
                                ForEach(AvatarSystem.avatars) { option in
                                    let isSelected = selectedAvatarID == option.id
                                    Button {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        selectedAvatarID = option.id
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: Radius.md)
                                                .fill(isSelected ? Color.habPrimary.opacity(0.08) : Color.habCard)
                                                .frame(height: 70)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: Radius.md)
                                                        .stroke(isSelected ? Color.habPrimary : Color.habBorderLight, lineWidth: isSelected ? 2 : 1)
                                                )
                                            
                                            Text(option.emoji)
                                                .font(.system(size: 32))
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        
                        // 3. Selector de Gradiente de Fondo
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("COLOR DE FONDO")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .padding(.horizontal, Spacing.xs)
                            
                            LazyVGrid(columns: gradientColumns, spacing: 12) {
                                ForEach(AvatarSystem.gradients) { bgGradient in
                                    let isSelected = selectedGradientID == bgGradient.id
                                    Button {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        selectedGradientID = bgGradient.id
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(bgGradient.gradient)
                                                .frame(width: 44, height: 44)
                                                .shadow(color: bgGradient.colors[0].opacity(0.1), radius: 2, x: 0, y: 1)
                                            
                                            if isSelected {
                                                Circle()
                                                    .strokeBorder(Color.white, lineWidth: 3)
                                                    .frame(width: 44, height: 44)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.xl2)
                    }
                }
            }
            .navigationTitle("Personalizar Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .font(.body)
                    .foregroundStyle(Color.habDanger)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        user.avatarUrl = currentAvatarString
                        try? modelContext.save()
                        dismiss()
                    }
                    .font(.body.bold())
                    .foregroundStyle(Color.habPrimary)
                }
            }
        }
    }
}

#Preview {
    AvatarPickerSheet(user: User(email: "test@example.com", passwordHash: ""))
}
