// ──────────────────────────────────────────────
// LoginView.swift — Vista de Inicio de Sesión
// ──────────────────────────────────────────────

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currentUserId") private var currentUserId: String = ""
    
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    
    // Alertas de error
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    // Feedback háptico
    private let hapticGenerator = UINotificationFeedbackGenerator()
    
    var isFormValid: Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanEmail.contains("@") && cleanEmail.contains(".") && password.count >= 6
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.habBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl2) {
                        
                        // Cabecera / Logo
                        VStack(spacing: Spacing.xs) {
                            ZStack {
                                Circle()
                                    .fill(Color.habPrimary.opacity(0.12))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.habPrimary)
                            }
                            .padding(.top, Spacing.xl2)
                            
                            Text("HabitOS")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundStyle(Color.primary)
                            
                            Text("Inicia sesión para continuar tu progreso")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.lg)
                        }
                        
                        // Formulario de login
                        VStack(spacing: Spacing.md) {
                            
                            // Campo Email
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
                            
                            // Campo Contraseña
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("CONTRASEÑA")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .padding(.horizontal, Spacing.xs)
                                
                                HStack {
                                    if isPasswordVisible {
                                        TextField("Mínimo 6 caracteres", text: $password)
                                            .autocorrectionDisabled()
                                            .textInputAutocapitalization(.never)
                                    } else {
                                        SecureField("Mínimo 6 caracteres", text: $password)
                                            .autocorrectionDisabled()
                                            .textInputAutocapitalization(.never)
                                    }
                                    
                                    Button {
                                        isPasswordVisible.toggle()
                                    } label: {
                                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                            .foregroundStyle(Color.secondary.opacity(0.8))
                                    }
                                }
                                .font(.body)
                                .padding()
                                .background(Color.habCard)
                                .cornerRadius(Radius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.md)
                                        .stroke(Color.primary.opacity(0.04), lineWidth: 1)
                                )
                            }
                            
                            // Botón Contraseña Olvidada
                            NavigationLink {
                                ForgotPasswordView()
                            } label: {
                                Text("¿Olvidaste tu contraseña?")
                                    .font(.system(.footnote, design: .rounded).bold())
                                    .foregroundStyle(Color.habPrimary)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, Spacing.lg)
                        
                        // Botones de acción
                        VStack(spacing: Spacing.md) {
                            Button {
                                handleLogin()
                            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Iniciar Sesión")
                                            .font(.system(.body, design: .rounded).bold())
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.habPrimary : Color.habPrimary.opacity(0.5))
                                .foregroundStyle(Color.white)
                                .cornerRadius(Radius.md)
                                .shadow(color: Color.habPrimary.opacity(isFormValid ? 0.15 : 0.0), radius: 6, x: 0, y: 3)
                            }
                            .disabled(!isFormValid || isLoading)
                            .buttonStyle(.plain)
                            
                            HStack(spacing: 4) {
                                Text("¿No tienes una cuenta?")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                
                                NavigationLink {
                                    RegisterView()
                                } label: {
                                    Text("Regístrate")
                                        .font(.system(.subheadline, design: .rounded).bold())
                                        .foregroundStyle(Color.habPrimary)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.xl)
                        
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Fallo de autenticación", isPresented: $showingErrorAlert) {
                Button("Aceptar", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func handleLogin() {
        isLoading = true
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Simular un retraso sutil de red/base de datos para el loading indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            do {
                let user = try AuthService.shared.login(email: email, password: password, modelContext: modelContext)
                hapticGenerator.notificationOccurred(.success)
                withAnimation {
                    currentUserId = user.id
                }
            } catch {
                hapticGenerator.notificationOccurred(.error)
                errorMessage = error.localizedDescription
                showingErrorAlert = true
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .modelContainer(for: [User.self, Habit.self], inMemory: true)
}
