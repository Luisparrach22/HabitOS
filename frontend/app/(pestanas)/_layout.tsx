import React from "react";
import { View, Pressable, StyleSheet } from "react-native";
import FontAwesome from "@expo/vector-icons/FontAwesome";
import { Tabs, useRouter } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { colors, radius, shadows, spacing } from "@/constantes/tema";

// ─── Tab bar icon component ───────────────────────────────────

function TabIcon({
  name,
  color,
}: {
  name: React.ComponentProps<typeof FontAwesome>["name"];
  color: string;
}) {
  return <FontAwesome size={22} name={name} color={color} />;
}

// ─── Custom tab bar with center + button ──────────────────────

function CustomTabBar({ state, descriptors, navigation }: any) {
  const insets = useSafeAreaInsets();
  const router = useRouter();

  // 1. Filtrar de manera segura solo las rutas visibles (ignoramos las ocultas)
  const visibleRoutes = state.routes.filter((route: any) => {
    const { options } = descriptors[route.key];
    // Excluimos las que tienen href: null o nombres específicos ocultos
    return options.href !== null && route.name !== "habits/[id]";
  });

  // 2. Calcular el punto medio exacto para el botón '+'
  // Si hay 3 rutas, el botón irá después de la 2da. Si hay 4, después de la 2da, etc.
  const middleIndex = Math.ceil(visibleRoutes.length / 2) - 1;

  return (
    <View style={[styles.tabBarContainer, { paddingBottom: Math.max(insets.bottom, spacing.md) }]}>
      <View style={styles.tabBar}>
        {visibleRoutes.map((route: any, index: number) => {
          const { options } = descriptors[route.key];

          // Recuperamos el índice original para saber si está activa
          const originalIndex = state.routes.findIndex(
            (r: any) => r.key === route.key,
          );
          const isFocused = state.index === originalIndex;
          const tintColor = isFocused ? colors.primary : colors.blueLight;

          const onPress = () => {
            const event = navigation.emit({
              type: "tabPress",
              target: route.key,
              canPreventDefault: true,
            });
            if (!isFocused && !event.defaultPrevented) {
              navigation.navigate(route.name);
            }
          };

          return (
            <React.Fragment key={route.key}>
              <Pressable style={styles.tabItem} onPress={onPress}>
                {options.tabBarIcon?.({
                  color: tintColor,
                  focused: isFocused,
                  size: 24,
                })}
              </Pressable>

              {/* Inserción dinámica del botón '+' */}
              {index === middleIndex && (
                <Pressable
                  style={styles.addButton}
                  onPress={() => router.push("/crear_habito")}
                >
                  <View style={{ marginTop: 2 }}>
                    <FontAwesome
                      name="plus"
                      size={24}
                      color={colors.textWhite}
                    />
                  </View>
                </Pressable>
              )}
            </React.Fragment>
          );
        })}
      </View>
    </View>
  );
}

// ─── Tabs Layout ──────────────────────────────────────────────

export default function TabLayout() {
  return (
    <Tabs
      tabBar={(props) => <CustomTabBar {...props} />}
      screenOptions={{
        headerShown: false,
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: "Home",
          tabBarIcon: ({ color }) => <TabIcon name="home" color={color} />,
        }}
      />
      <Tabs.Screen
        name="estadisticas"
        options={{
          title: "Stats",
          tabBarIcon: ({ color }) => <TabIcon name="bar-chart" color={color} />,
        }}
      />
      <Tabs.Screen
        name="habits/[id]"
        options={{
          href: null,
        }}
      />
      <Tabs.Screen
        name="perfil"
        options={{
          title: "Perfil",
          tabBarIcon: ({ color }) => <TabIcon name="user" color={color} />,
        }}
      />
    </Tabs>
  );
}

// ─── Styles ───────────────────────────────────────────────────

const styles = StyleSheet.create({
  tabBarContainer: {
    position: "absolute",
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: "transparent",
    alignItems: "center",
    paddingHorizontal: spacing.xl, // Reducimos margen para pantallas pequeñas
  },
  tabBar: {
    flexDirection: "row",
    backgroundColor: colors.card,
    borderRadius: radius.full,
    paddingHorizontal: spacing.md,
    alignItems: "center",
    justifyContent: "space-between",
    ...shadows.cardHeavy,
    width: "100%",
    height: 60, // Reducido de 64 a 60
  },
  tabItem: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  addButton: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: colors.primary,
    alignItems: "center",
    justifyContent: "center",
    marginHorizontal: spacing.sm,
    ...shadows.cardHeavy,
  },
});
