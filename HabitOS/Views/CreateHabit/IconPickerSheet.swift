// ──────────────────────────────────────────────
// IconPickerSheet.swift — Selector de Iconos por Categoría
// ──────────────────────────────────────────────
// Vista modal en SwiftUI que presenta el catálogo de
// iconos SF Symbols organizado en secciones/categorías.

import SwiftUI

struct IconPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIcon: String
    let themeColor: Color
    
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.adaptive(minimum: 50, maximum: 60))
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if filteredCategories().isEmpty {
                    emptySearchResultView
                } else {
                    LazyVStack(alignment: .leading, spacing: Spacing.xl) {
                        ForEach(filteredCategories()) { category in
                            categorySection(category)
                        }
                    }
                    .padding()
                }
            }
            .background(Color.habBackground)
            .navigationTitle("Elige un Icono")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Buscar iconos...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.habPrimary)
                }
            }
        }
    }
    
    private func filteredCategories() -> [IconCategory] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        if query.isEmpty {
            return iconCategories
        }
        return iconCategories.compactMap { category in
            let filtered = category.icons.filter { $0.localizedCaseInsensitiveContains(query) }
            return filtered.isEmpty ? nil : IconCategory(label: category.label, icons: filtered)
        }
    }
    
    @ViewBuilder
    private func categorySection(_ category: IconCategory) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(category.label)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(Color.secondary)
                .padding(.horizontal, Spacing.xs)
            
            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(category.icons, id: \.self) { iconName in
                    IconCell(iconName: iconName, selectedIcon: $selectedIcon, themeColor: themeColor) {
                        dismiss()
                    }
                }
            }
            
            Divider()
                .opacity(0.5)
                .padding(.top, Spacing.sm)
        }
    }
    
    private var emptySearchResultView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text("Sin resultados")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Prueba a buscar otro término o explora las categorías.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, Spacing.xl4)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Celda de Icono con Aislamiento de Contexto de Compilación
struct IconCell: View {
    let iconName: String
    @Binding var selectedIcon: String
    let themeColor: Color
    let onSelect: () -> Void
    
    var body: some View {
        let isActive = selectedIcon == iconName
        
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            selectedIcon = iconName
            onSelect()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(isActive ? themeColor : Color.habCard)
                    .frame(width: 50, height: 50)
                    .shadow(
                        color: Color.black.opacity(isActive ? 0.06 : 0.01),
                        radius: 3, x: 0, y: 1.5
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(Color.primary.opacity(0.04), lineWidth: 1)
                    )
                
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(isActive ? Color.white : Color.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previsualización
#Preview {
    IconPickerSheet(selectedIcon: .constant("heart"), themeColor: .habPrimary)
}
