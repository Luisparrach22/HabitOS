import FontAwesome from '@expo/vector-icons/FontAwesome';
import { DarkTheme, DefaultTheme, ThemeProvider } from '@react-navigation/native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useFonts, Outfit_400Regular, Outfit_500Medium, Outfit_600SemiBold, Outfit_700Bold } from '@expo-google-fonts/outfit';
import { Stack, useRouter, useSegments } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { useEffect } from 'react';
import 'react-native-reanimated';

import { useColorScheme } from '@/hooks/useColorScheme';
import { AuthProvider, useAuth } from '@/contextos/ContextoAuth';

export {
  // Catch any errors thrown by the Layout component.
  ErrorBoundary,
} from 'expo-router';

export const unstable_settings = {
  // Ensure that reloading on `/crear_habito` keeps a back button present.
  initialRouteName: '(pestanas)',
};

// Prevent the splash screen from auto-hiding before asset loading is complete.
SplashScreen.preventAutoHideAsync();

// Crear un QueryClient global
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 2,
      staleTime: 1000 * 60, // 1 minuto
    },
  },
});

export default function RootLayout() {
  const [loaded, error] = useFonts({
    'Outfit-Regular': Outfit_400Regular,
    'Outfit-Medium': Outfit_500Medium,
    'Outfit-SemiBold': Outfit_600SemiBold,
    'Outfit-Bold': Outfit_700Bold,
    SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
    ...FontAwesome.font,
  });

  // Expo Router uses Error Boundaries to catch errors in the navigation tree.
  useEffect(() => {
    if (error) throw error;
  }, [error]);

  useEffect(() => {
    if (loaded) {
      SplashScreen.hideAsync();
    }
  }, [loaded]);

  if (!loaded) {
    return null;
  }

  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <RootLayoutNav />
      </AuthProvider>
    </QueryClientProvider>
  );
}

/**
 * Protector de rutas: redirige a /bienvenida si no hay sesión,
 * y a /(pestanas) si ya está autenticado y está en pantallas públicas.
 */
function RootLayoutNav() {
  const colorScheme = useColorScheme();
  const { isAuthenticated, isLoading } = useAuth();
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    if (isLoading) return;

    const inAuthGroup = segments[0] === 'acceso' || segments[0] === 'bienvenida';

    if (!isAuthenticated && !inAuthGroup) {
      // No autenticado y no está en rutas públicas → redirigir a onboarding
      router.replace('/bienvenida');
    } else if (isAuthenticated && inAuthGroup) {
      // Autenticado pero está en rutas públicas → redirigir a tabs
      router.replace('/(pestanas)');
    }
  }, [isAuthenticated, isLoading, segments]);

  return (
    <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
      <Stack>
        <Stack.Screen name="bienvenida" options={{ headerShown: false }} />
        <Stack.Screen name="acceso" options={{ headerShown: false }} />
        <Stack.Screen name="(pestanas)" options={{ headerShown: false }} />
        <Stack.Screen name="crear_habito" options={{ presentation: 'modal' }} />
      </Stack>
    </ThemeProvider>
  );
}
