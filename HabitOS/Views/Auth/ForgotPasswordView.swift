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
            Color.habBackground
                .ignoresSafeArea()
            
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
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.lg)
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("CORREO ELECTRÓNICO")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .padding(.horizontal, Spacing.xs)
                        
                        TextField("ejemplo@correo.com", text: $email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .font(.body)
                            .padding()
                            .background(Color.habCard)
                            .cornerRadius(Radius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.md)
                                    .stroke(Color.primary.opacity(0.04), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, Spacing.lg)
                    
                    Button {
                        handleResetPassword()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Enviar Enlace")
                                    .font(.system(.body, design: .rounded).bold())
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isEmailValid ? Color.habPrimary : Color.habPrimary.opacity(0.5))
                        .foregroundStyle(Color.white)
                        .cornerRadius(Radius.md)
                        .shadow(color: Color.habPrimary.opacity(isEmailValid ? 0.15 : 0.0), radius: 6, x: 0, y: 3)
                    }
                    .disabled(!isEmailValid || isLoading)
                    .buttonStyle(.plain)
                    .padding(.horizontal, Spacing.lg)
                    
                } else {
                    // Estado Final: Confirmación de envío
                    VStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.habSuccess.opacity(0.12))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Color.habSuccess)
                        }
                        .padding(.top, Spacing.lg)
                        
                        Text("¡Correo Enviado!")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(Color.primary)
                        
                        Text("Hemos enviado las instrucciones a \(email). Revisa tu bandeja de entrada.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.lg)
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Volver al Inicio de Sesión")
                                .font(.system(.body, design: .rounded).bold())
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.habPrimary)
                                .foregroundStyle(Color.white)
                                .cornerRadius(Radius.md)
                        }
                        .padding(.top, Spacing.md)
                        .buttonStyle(.plain)
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
