// ──────────────────────────────────────────────
// PaywallView.swift — Pantalla de Pago Premium
// ──────────────────────────────────────────────
// Interfaz llamativa y animada que muestra las ventajas
// de HabitOS Pro, permite iniciar la compra de suscripción
// y restaurar compras anteriores.

import SwiftUI
import StoreKit
import SwiftData

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Acceso al servicio observable
    private var storeManager = StoreManager.shared
    
    // Estados para animaciones
    @State private var animateItems = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Lista de beneficios premium con iconos llamativos
    private let benefits = [
        BenefitItem(icon: "timer", color: "#00F5D4", title: "Modo Enfoque & Audio", desc: "Cronómetro Pomodoro de hasta 120 min con paisajes sonoros ambientales y 2X XP."),
        BenefitItem(icon: "dragon.fill", color: "#8B5CF6", title: "Misiones Boss Battles", desc: "Enfrenta al Monstruo de la Procrastinación semanalmente y reclama recompensas legendarias."),
        BenefitItem(icon: "brain.head.profile", color: "#8B5CF6", title: "Diagnóstico Inteligente", desc: "Descubre tu Día de Oro, alertas de racha en riesgo y patrones de horario de alto rendimiento."),
        BenefitItem(icon: "infinity", color: "#EC4899", title: "Hábitos Ilimitados", desc: "Supera el límite de 5 hábitos activos y añade todos los que necesites."),
        BenefitItem(icon: "paintpalette.fill", color: "#F5A623", title: "Temas, Colores & Iconos", desc: "Desbloquea temas globales (Cyberpunk, Minimal Dark), 6 colores Pro e iconos alternativos.")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Spacing.xl2) {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .glassEffect(.regular.tint(Color.habPrimary.opacity(0.75)), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .accessibilityHidden(true)

                        Text("HabitOS Pro")
                            .font(.largeTitle.weight(.bold))

                        Text("Más control sobre tus hábitos.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Spacing.xl3)

                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        ForEach(benefits.indices, id: \.self) { index in
                            let item = benefits[index]
                            HStack(alignment: .top, spacing: Spacing.md) {
                                Image(systemName: item.icon)
                                    .font(.title3)
                                    .foregroundStyle(Color.habPrimary)
                                    .frame(width: 32)
                                    .accessibilityHidden(true)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.headline)
                                    Text(item.desc)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.xl2)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Acceso mensual")
                                .font(.headline)
                            Text("Cancela cuando quieras")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        }
                        Spacer()
                        Text("$4.99 / mes")
                            .font(.headline)
                    }
                    .padding(Spacing.lg)
                    .glassCard(Radius.lg)
                    .padding(.horizontal, Spacing.lg)
                }
                .padding(.bottom, Spacing.xl2)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)

            VStack(spacing: Spacing.md) {
                Button {
                    triggerPurchase()
                } label: {
                    HStack(spacing: 8) {
                        if storeManager.isPurchasing {
                            ProgressView().tint(.white)
                        }
                        Text(storeManager.isPurchasing ? "Procesando…" : "Suscribirse")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.glassProminent)
                .tint(Color.habPrimary)
                .disabled(storeManager.isPurchasing)

                HStack(spacing: Spacing.xl) {
                    Button("Restaurar compras") { triggerRestore() }
                    Button("Términos") {
                        alertMessage = "Términos de servicio y políticas disponibles en habitos.app/terms"
                        showingAlert = true
                    }
                }
                .font(.footnote)
                .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal, Spacing.xl2)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.lg)
            .background(.bar)
        }
        .background { AuroraBackground() }
        .overlay(alignment: .topTrailing) {
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
            .padding(.trailing, Spacing.sm)
            .padding(.top, Spacing.sm)
        }
        .onAppear {
            Task {
                await storeManager.loadProducts()
            }
        }
        .alert("HabitOS Pro", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Acciones de compra
    
    private func triggerPurchase() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        Task {
            let success = await storeManager.purchasePro(modelContext: modelContext)
            if success {
                alertMessage = "Ahora eres usuario HabitOS Pro."
                showingAlert = true
                
                // Feedback háptico de éxito
                let successGen = UINotificationFeedbackGenerator()
                successGen.notificationOccurred(.success)
                
                // Desestimar tras retraso corto
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } else {
                if !storeManager.isPurchasing {
                    alertMessage = "No se pudo procesar la suscripción. Inténtalo de nuevo."
                    showingAlert = true
                }
            }
        }
    }
    
    private func triggerRestore() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        Task {
            await storeManager.restorePurchases(modelContext: modelContext)
            if storeManager.hasPro {
                alertMessage = "Suscripción restaurada exitosamente."
                showingAlert = true
                
                let successGen = UINotificationFeedbackGenerator()
                successGen.notificationOccurred(.success)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } else {
                alertMessage = "No se encontraron compras anteriores activas."
                showingAlert = true
            }
        }
    }
}

// Estructura de apoyo para listar beneficios
struct BenefitItem {
    let icon: String
    let color: String
    let title: String
    let desc: String
}

// MARK: - Previsualización
#Preview {
    PaywallView()
}
