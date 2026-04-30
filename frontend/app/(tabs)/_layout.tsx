import React from 'react';
import { View, Pressable, StyleSheet } from 'react-native';
import FontAwesome from '@expo/vector-icons/FontAwesome';
import { Tabs, useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { colors, radius, shadows, spacing } from '@/constants/theme';

// ─── Tab bar icon component ───────────────────────────────────

function TabIcon({ name, color }: { name: React.ComponentProps<typeof FontAwesome>['name']; color: string }) {
  return <FontAwesome size={22} name={name} color={color} />;
}

// ─── Custom tab bar with center + button ──────────────────────

function CustomTabBar({ state, descriptors, navigation }: any) {
  const insets = useSafeAreaInsets();
  const router = useRouter();

  return (
    <View style={[styles.tabBarContainer, { paddingBottom: insets.bottom }]}>
      <View style={styles.tabBar}>
        {state.routes.map((route: any, index: number) => {
          // Skip the habits/[id] route from showing in the tab bar
          if (route.name === 'habits/[id]') return null;

          const { options } = descriptors[route.key];
          const isFocused = state.index === index;
          const tintColor = isFocused ? colors.primary : colors.blueLight;

          // Insert the "+" button after the second tab icon
          const isMiddleInsertPoint = index === 1;

          const onPress = () => {
            const event = navigation.emit({
              type: 'tabPress',
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
                {options.tabBarIcon?.({ color: tintColor, focused: isFocused, size: 22 })}
              </Pressable>

              {isMiddleInsertPoint && (
                <Pressable
                  style={styles.addButton}
                  onPress={() => {
                    // TODO: Navigate to add habit modal
                    router.push('/modal');
                  }}
                >
                  <FontAwesome name="plus" size={20} color={colors.textWhite} />
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
          title: 'Home',
          tabBarIcon: ({ color }) => <TabIcon name="home" color={color} />,
        }}
      />
      <Tabs.Screen
        name="two"
        options={{
          title: 'Stats',
          tabBarIcon: ({ color }) => <TabIcon name="bar-chart" color={color} />,
        }}
      />
      <Tabs.Screen
        name="habits/[id]"
        options={{
          href: null, // Hide from tab bar
        }}
      />
    </Tabs>
  );
}

// ─── Styles ───────────────────────────────────────────────────

const styles = StyleSheet.create({
  tabBarContainer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'transparent',
    alignItems: 'center',
    paddingHorizontal: spacing['3xl'],
  },
  tabBar: {
    flexDirection: 'row',
    backgroundColor: colors.card,
    borderRadius: radius.full,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing['2xl'],
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.sm,
    ...shadows.cardHeavy,
    width: 260,
  },
  tabItem: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: spacing.sm,
  },
  addButton: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: spacing.lg,
    ...shadows.card,
  },
});
