// ──────────────────────────────────────────────
// ForgotPasswordView.swift — Recuperación de Contraseña
// ──────────────────────────────────────────────

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var isLoading = false
    @State private var emailSent = false
    
    // Feedback
    private let hapticGenerator = UINotificationFeedbackGenerator()
    
    var isEmailValid: Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanEmail.contains("@") && cleanEmail.contains(".")
    }
    
    var body: some View {
        ZStack {
            AuroraBackground()
            
            VStack(spacing: Spacing.xl2) {
                
                if !emailSent {
                    // Estado Inicial: Solicitar Correo
                    VStack(spacing: Spacing.xs) {
                        Text("¿Olvidaste tu contraseña?")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.center)
                            .padding(.top, Spacing.lg)
                        
                        Text("Introduce tu correo y te enviaremos instrucciones para restablecer tu cuenta.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.lg)
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Correo electrónico")
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                            .padding(.horizontal, Spacing.xs)
                        
                        TextField("ejemplo@correo.com", text: $email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .font(.body)
                            .padding()
                            .glassCard(Radius.md)
                    }
                    .padding(.horizontal, Spacing.lg)
                    
                    Button {
                        handleResetPassword()
                    } label: {
                        Group {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Enviar enlace").font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color.habPrimary)
                    .disabled(!isEmailValid || isLoading)
                    .padding(.horizontal, Spacing.lg)
                    
                } else {
                    // Estado Final: Confirmación de envío
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(Color.habSuccess, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .padding(.top, Spacing.lg)
                            .accessibilityHidden(true)
                        
                        Text("Correo enviado")
                            .font(.title2.weight(.bold))
                        
                        Text("Hemos enviado las instrucciones a \(email). Revisa tu bandeja de entrada.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.lg)
                        
                        Button("Volver a iniciar sesión") { dismiss() }
                            .buttonStyle(.glassProminent)
                            .tint(Color.habPrimary)
                            .padding(.top, Spacing.md)
                    }
                }
                
                Spacer()
            }
        }
        .navigationTitle("Recuperar cuenta")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleResetPassword() {
        isLoading = true
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            hapticGenerator.notificationOccurred(.success)
            withAnimation {
                emailSent = true
            }
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
}
