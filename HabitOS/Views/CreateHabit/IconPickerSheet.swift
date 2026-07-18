// ──────────────────────────────────────────────
// IconPickerSheet.swift — Selector de Iconos por Categoría
// ──────────────────────────────────────────────
// Vista modal en SwiftUI que presenta el catálogo de
// iconos SF Symbols organizado en secciones/categorías.
// Mapea la lógica del selector de iconos en React Native.

import SwiftUI

struct IconPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIcon: String
    let themeColor: Color
    
    // Configuración del Grid: 5 columnas adaptables
    private let columns = [
        GridItem(.adaptive(minimum: 50, maximum: 60))
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    
                    // Recorre cada categoría declarada en HabitColors
                    ForEach(iconCategories) { category in
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            
                            // Nombre de la categoría
                            Text(category.label)
                                .font(.habHeadline)
                                .foregroundStyle(Color.habTextSecondary)
                                .padding(.horizontal, Spacing.xs)
                            
                            // Rejilla de iconos
                            LazyVGrid(columns: columns, spacing: Spacing.md) {
                                ForEach(category.icons, id: \.self) { iconName in
                                    let isActive = selectedIcon == iconName
                                    
                                    Button {
                                        selectedIcon = iconName
                                        dismiss() // Cierra el modal
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: Radius.md)
                                                .fill(isActive ? themeColor : Color.habCard)
                                                .frame(width: 50, height: 50)
                                                .shadow(
                                                    color: Color.habTextDark.opacity(isActive ? 0.1 : 0.02),
                                                    radius: 4, x: 0, y: 1
                                                )
                                            
                                            Image(systemName: iconName)
                                                .font(.system(size: 20))
                                                .foregroundStyle(isActive ? Color.white : Color.habTextPrimary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.sm)
                        
                        Divider()
                            .background(Color.habBorder)
                    }
                }
                .padding()
            }
            .background(Color.habBackground)
            .navigationTitle("Elige un Icono")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .font(.habHeadline)
                    .foregroundStyle(Color.habPrimary)
                }
            }
        }
    }
}

// MARK: - Previsualización

#Preview {
    IconPickerSheet(selectedIcon: .constant("heart"), themeColor: .habPrimary)
}
