// ──────────────────────────────────────────────
// RegisterView.swift — Vista de Registro de Cuenta
// ──────────────────────────────────────────────

import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currentUserId") private var currentUserId: String = ""
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    
    // Alertas de error
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    private let hapticGenerator = UINotificationFeedbackGenerator()
    
    // Nivel de seguridad de la contraseña
    enum PasswordStrength {
        case empty, weak, medium, strong
        
        var label: String {
            switch self {
            case .empty: return ""
            case .weak: return "Contraseña Débil"
            case .medium: return "Contraseña Media"
            case .strong: return "Contraseña Fuerte"
            }
        }
        
        var color: Color {
            switch self {
            case .empty: return .clear
            case .weak: return .habDanger
            case .medium: return .orange
            case .strong: return .habSuccess
            }
        }
    }
    
    private var passwordStrength: PasswordStrength {
        if password.isEmpty { return .empty }
        if password.count < 6 { return .weak }
        
        // Criterios de fuerza
        let hasNumbers = password.contains(where: { $0.isNumber })
        let hasUppercase = password.contains(where: { $0.isUppercase })
        let hasLowercase = password.contains(where: { $0.isLowercase })
        
        if password.count >= 8 && hasNumbers && (hasUppercase || hasLowercase) {
            return .strong
        }
        return .medium
    }
    
    var isFormValid: Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanEmail.contains("@") &&
               cleanEmail.contains(".") &&
               password.count >= 6 &&
               password == confirmPassword
    }
    
    var body: some View {
        ZStack {
            Color.habBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    
                    // Cabecera
                    VStack(spacing: Spacing.xs) {
                        Text("Crear Cuenta")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Color.primary)
                        
                        Text("Completa tus datos para empezar en HabitOS")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.top, Spacing.lg)
                    
                    // Campos del formulario
                    VStack(spacing: Spacing.md) {
                        
                        // Nombre
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("NOMBRE DE PILA")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .padding(.horizontal, Spacing.xs)
                            
                            TextField("Tu nombre", text: $name)
                                .font(.body)
                                .padding()
                                .background(Color.habCard)
                                .cornerRadius(Radius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.md)
                                        .stroke(Color.primary.opacity(0.04), lineWidth: 1)
                                )
                        }
                        
                        // Email
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
                        
                        // Contraseña
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
                            
                            // Medidor de fuerza
                            if passwordStrength != .empty {
                                HStack(spacing: 6) {
                                    Text(passwordStrength.label)
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundStyle(passwordStrength.color)
                                    
                                    Spacer()
                                    
                                    // Barras indicadoras
                                    HStack(spacing: 3) {
                                        Rectangle()
                                            .fill(passwordStrength == .weak || passwordStrength == .medium || passwordStrength == .strong ? passwordStrength.color : Color.secondary.opacity(0.2))
                                            .frame(width: 25, height: 4)
                                            .cornerRadius(2)
                                        
                                        Rectangle()
                                            .fill(passwordStrength == .medium || passwordStrength == .strong ? passwordStrength.color : Color.secondary.opacity(0.2))
                                            .frame(width: 25, height: 4)
                                            .cornerRadius(2)
                                        
                                        Rectangle()
                                            .fill(passwordStrength == .strong ? passwordStrength.color : Color.secondary.opacity(0.2))
                                            .frame(width: 25, height: 4)
                                            .cornerRadius(2)
                                    }
                                }
                                .padding(.top, 2)
                                .padding(.horizontal, Spacing.xs)
                            }
                        }
                        
                        // Confirmar Contraseña
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("CONFIRMAR CONTRASEÑA")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .padding(.horizontal, Spacing.xs)
                            
                            SecureField("Repite tu contraseña", text: $confirmPassword)
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
                            
                            if !confirmPassword.isEmpty && password != confirmPassword {
                                Text("Las contraseñas no coinciden")
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.habDanger)
                                    .padding(.horizontal, Spacing.xs)
                                    .padding(.top, 2)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    
                    // Botón de Registro
                    VStack(spacing: Spacing.md) {
                        Button {
                            handleRegister()
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Crear Cuenta")
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
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                    
                }
            }
        }
        .navigationTitle("Registro")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Fallo al registrarse", isPresented: $showingErrorAlert) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleRegister() {
        isLoading = true
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            do {
                let user = try AuthService.shared.register(
                    name: name,
                    email: email,
                    password: password,
                    modelContext: modelContext
                )
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
    NavigationStack {
        RegisterView()
            .modelContainer(for: [User.self, Habit.self], inMemory: true)
    }
}
