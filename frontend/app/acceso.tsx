import React, { useState } from "react";
import {
  StyleSheet,
  TextInput,
  Pressable,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Alert,
  View,
  Text,
  Image,
} from "react-native";
import { useAuth } from "@/contextos/ContextoAuth";
import { router } from "expo-router";
import * as Localization from "expo-localization";
import {
  colors,
  radius,
  shadows,
  typography,
  spacing,
} from "@/constantes/tema";
import BotonAccion from "@/componentes/BotonAccion";
import LogoSVG from "@/assets/images/LogoSVG.svg";

export default function LoginScreen() {
  const { login, signup } = useAuth();
  const [isSignup, setIsSignup] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    if (!email.trim() || !password.trim()) {
      Alert.alert("Error", "Por favor ingresa email y contraseña.");
      return;
    }

    setLoading(true);
    try {
      if (isSignup) {
        // Detectar timezone del dispositivo automáticamente
        const timezone = Localization.getCalendars()[0]?.timeZone || "UTC";
        await signup(
          email.trim(),
          password,
          name.trim() || undefined,
          timezone,
        );
      } else {
        await login(email.trim(), password);
      }
      router.replace("/(pestanas)");
    } catch (error: any) {
      const message =
        error.response?.data?.error || "Error de conexión. Intenta de nuevo.";
      Alert.alert("Error", message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === "ios" ? "padding" : "height"}
    >
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
      >
        {/* Header */}
        <View style={styles.headerContainer}>
          <LogoSVG
            width={80}
            height={80}
            style={{ marginBottom: spacing.md }}
          />
          <Text style={styles.subtitle}>
            {isSignup ? "Crea tu cuenta" : "Inicia sesión"}
          </Text>
        </View>

        {/* Form */}
        <View style={styles.formContainer}>
          {isSignup && (
            <View style={styles.inputWrapper}>
              <Text style={styles.label}>Nombre</Text>
              <TextInput
                style={styles.input}
                placeholder="Tu nombre"
                placeholderTextColor={colors.textLight}
                value={name}
                onChangeText={setName}
                autoCapitalize="words"
              />
            </View>
          )}

          <View style={styles.inputWrapper}>
            <Text style={styles.label}>Email</Text>
            <TextInput
              style={styles.input}
              placeholder="tu@email.com"
              placeholderTextColor={colors.textLight}
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
              autoComplete="email"
            />
          </View>

          <View style={styles.inputWrapper}>
            <Text style={styles.label}>Contraseña</Text>
            <TextInput
              style={styles.input}
              placeholder="Mínimo 6 caracteres"
              placeholderTextColor={colors.textLight}
              value={password}
              onChangeText={setPassword}
              secureTextEntry
            />
          </View>

          <BotonAccion
            title={isSignup ? "Crear cuenta" : "Iniciar sesión"}
            onPress={handleSubmit}
            disabled={loading}
            style={styles.button}
          />

          <Pressable
            style={styles.toggleButton}
            onPress={() => setIsSignup(!isSignup)}
          >
            <Text style={styles.toggleText}>
              {isSignup
                ? "¿Ya tienes cuenta? Inicia sesión"
                : "¿No tienes cuenta? Regístrate"}
            </Text>
          </Pressable>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: "center",
    paddingHorizontal: spacing["2xl"],
    paddingVertical: spacing["4xl"],
  },
  headerContainer: {
    alignItems: "center",
    marginBottom: spacing["4xl"],
  },
  logo: {
    ...typography.largeTitle,
    color: colors.textDark,
    letterSpacing: 2,
  },
  subtitle: {
    ...typography.title3,
    color: colors.textSecondary,
    marginTop: spacing.sm,
  },
  formContainer: {
    backgroundColor: colors.card,
    borderRadius: radius["2xl"],
    padding: spacing["2xl"],
    ...shadows.cardHeavy,
  },
  inputWrapper: {
    marginBottom: spacing.lg,
  },
  label: {
    ...typography.subhead,
    color: colors.textSecondary,
    marginBottom: 6,
  },
  input: {
    backgroundColor: colors.cardMuted,
    borderRadius: radius.md,
    padding: 14,
    ...typography.body,
    color: colors.textDark,
    borderWidth: 1,
    borderColor: colors.border,
  },
  button: {
    marginTop: spacing.sm,
    width: "100%",
  },
  toggleButton: {
    marginTop: spacing.lg,
    alignItems: "center",
  },
  toggleText: {
    ...typography.subhead,
    color: colors.primary,
  },
});
