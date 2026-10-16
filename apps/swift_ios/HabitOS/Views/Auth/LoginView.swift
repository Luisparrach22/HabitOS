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
                AuroraBackground()
                
                ScrollView {
                    VStack(spacing: Spacing.xl2) {
                        
                        // Cabecera
                        VStack(spacing: Spacing.sm) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 72, height: 72)
                                .glassEffect(.regular.tint(Color.habPrimary.opacity(0.75)), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .padding(.top, Spacing.xl3)
                                .accessibilityHidden(true)
                            
                            Text("HabitOS")
                                .font(.largeTitle.weight(.bold))
                            
                            Text("Inicia sesión para continuar")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                        }
                        
                        // Formulario de login
                        VStack(spacing: Spacing.md) {
                            
                            // Campo Email
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
                            
                            // Campo Contraseña
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Contraseña")
                                    .font(.footnote)
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
                                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                            .foregroundStyle(Color.secondary)
                                            .frame(width: 44, height: 44)
                                    }
                                }
                                .font(.body)
                                .padding()
                                .glassCard(Radius.md)
                            }
                            
                            // Botón Contraseña Olvidada
                            NavigationLink {
                                ForgotPasswordView()
                            } label: {
                                Text("¿Olvidaste tu contraseña?")
                                    .font(.footnote.weight(.semibold))
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
                                Group {
                                    if isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Iniciar sesión").font(.headline)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                            }
                            .buttonStyle(.glassProminent)
                            .tint(Color.habPrimary)
                            .disabled(!isFormValid || isLoading)
                            
                            HStack(spacing: 4) {
                                Text("¿No tienes una cuenta?")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondary)
                                
                                NavigationLink {
                                    RegisterView()
                                } label: {
                                    Text("Regístrate")
                                        .font(.subheadline.weight(.semibold))
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
        
        Task {
            do {
                let user: User
                do {
                    user = try await AuthService.shared.loginWithSupabase(email: email, password: password, modelContext: modelContext)
                } catch {
                    // Fallback a login local si no hay internet o falla la red
                    user = try AuthService.shared.login(email: email, password: password, modelContext: modelContext)
                }
                
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
