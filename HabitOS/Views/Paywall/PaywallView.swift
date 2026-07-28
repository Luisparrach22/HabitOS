// ──────────────────────────────────────────────
// PaywallView.swift — Pantalla de Pago Premium
// ──────────────────────────────────────────────
// Interfaz llamativa y animada que muestra las ventajas
// de HabitOS Pro, permite iniciar la compra de suscripción
// y restaurar compras anteriores.

import SwiftUI
import StoreKit

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
        BenefitItem(icon: "infinity", color: "#8B5CF6", title: "Hábitos Ilimitados", desc: "Supera el límite de 5 hábitos activos y añade todos los que necesites."),
        BenefitItem(icon: "paintpalette.fill", color: "#EC4899", title: "Colores Premium", desc: "Desbloquea 6 colores exclusivos para personalizar al máximo tus hábitos."),
        BenefitItem(icon: "calendar.badge.clock", color: "#00F5D4", title: "Mapa de Calor Avanzado", desc: "Visualiza tu consistencia mensual con la rejilla completa en Estadísticas."),
        BenefitItem(icon: "lock.shield.fill", color: "#F5A623", title: "Acceso Futuro Completo", desc: "Sé el primero en disfrutar de todos los nuevos complementos de personalización.")
    ]
    
    var body: some View {
        ZStack {
            // Fondo oscuro e inmersivo con gradientes circulares
            Color(hex: "#0D0F14")
                .ignoresSafeArea()
            
            // Efectos de luces de fondo (Glow)
            VStack {
                HStack {
                    Circle()
                        .fill(Color(hex: "#8B5CF6").opacity(0.15))
                        .frame(width: 250, height: 250)
                        .blur(radius: 60)
                        .offset(x: -80, y: -50)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color(hex: "#00F5D4").opacity(0.12))
                        .frame(width: 280, height: 280)
                        .blur(radius: 80)
                        .offset(x: 100, y: 100)
                }
            }
            .ignoresSafeArea()
            
            // Contenido principal
            VStack(spacing: 0) {
                
                // Cabecera con botón de cerrar
                HStack {
                    Spacer()
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.white.opacity(0.4), .white.opacity(0.1))
                            .padding(.trailing, 24)
                            .padding(.top, 16)
                    }
                    .buttonStyle(.plain)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.xl2) {
                        
                        // Icono + Título del paywall
                        VStack(spacing: Spacing.xs) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color(hex: "#8B5CF6"), Color(hex: "#EC4899")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 72, height: 72)
                                    .shadow(color: Color(hex: "#8B5CF6").opacity(0.5), radius: 15)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .scaleEffect(animateItems ? 1.0 : 0.8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: animateItems)
                            
                            Text("HabitOS Pro")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.top, 8)
                            
                            Text("Lleva el control de tu vida al siguiente nivel")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 10)
                        
                        // Lista de Beneficios
                        VStack(alignment: .leading, spacing: Spacing.lg) {
                            ForEach(0..<benefits.count, id: \.self) { index in
                                let item = benefits[index]
                                HStack(alignment: .top, spacing: Spacing.md) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: item.color).opacity(0.15))
                                            .frame(width: 42, height: 42)
                                        
                                        Image(systemName: item.icon)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(Color(hex: item.color))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.title)
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                        
                                        Text(item.desc)
                                            .font(.system(size: 13))
                                            .foregroundStyle(.white.opacity(0.5))
                                            .lineLimit(2)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .offset(x: animateItems ? 0 : -50, y: 0)
                                .opacity(animateItems ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1 + 0.2), value: animateItems)
                            }
                        }
                        .padding(.vertical, 10)
                        
                        // Caja del Plan Mensual (Estilo Tarjeta de Suscripción)
                        VStack(spacing: Spacing.xs) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Acceso Mensual")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                    
                                    Text("Cancela cuando quieras")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 0) {
                                    Text("$4.99")
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text("/ mes")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: Radius.xl)
                                    .fill(.white.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Radius.xl)
                                            .stroke(.white.opacity(0.12), lineWidth: 1.5)
                                    )
                            )
                        }
                        .padding(.horizontal, 24)
                        .scaleEffect(animateItems ? 1.0 : 0.95)
                        .opacity(animateItems ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.5).delay(0.6), value: animateItems)
                    }
                }
                
                // Botón de Compra + Enlaces Legales en la base
                VStack(spacing: Spacing.md) {
                    Button {
                        triggerPurchase()
                    } label: {
                        HStack {
                            if storeManager.isPurchasing {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 8)
                            }
                            Text(storeManager.isPurchasing ? "Procesando..." : "Suscribirse ahora")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#8B5CF6"), Color(hex: "#EC4899")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(Radius.xl2)
                        .shadow(color: Color(hex: "#EC4899").opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(storeManager.isPurchasing)
                    .buttonStyle(.plain)
                    
                    // Botones de políticas y restauración
                    HStack(spacing: Spacing.xl) {
                        Button {
                            triggerRestore()
                        } label: {
                            Text("Restaurar Compras")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                        
                        Text("•")
                            .foregroundStyle(.white.opacity(0.3))
                        
                        Button {
                            // Link simulado a términos
                            alertMessage = "Términos de servicio y políticas disponibles en habitos.app/terms"
                            showingAlert = true
                        } label: {
                            Text("Términos")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .background(Color(hex: "#0D0F14"))
            }
        }
        .onAppear {
            animateItems = true
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
                alertMessage = "¡Felicidades! Ahora eres un usuario HabitOS Pro."
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
