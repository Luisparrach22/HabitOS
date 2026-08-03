// ──────────────────────────────────────────────
// main_tab_screen.dart — Navegación Principal por Pestañas
// ──────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../core/config/supabase_config.dart';
import '../../core/network/supabase_service.dart';
import '../../features/auth/data/user_model.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/profile_tab.dart';
import '../../features/habits/data/habit_model.dart';
import '../../features/habits/presentation/dashboard_tab.dart';
import '../../features/habits/presentation/stats_tab.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;
  UserModel? _currentUser;
  List<HabitModel> _habits = [];
  Set<String> _completedHabitIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Carga los datos del usuario y sus hábitos desde Supabase.
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      if (session != null) {
        final userId = session.user.id.toLowerCase();
        final userMap = await SupabaseConfig.client
            .from('User')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (userMap != null) {
          _currentUser = UserModel.fromJson(userMap);
          _habits = await SupabaseService.instance.fetchHabits(userId);
          _completedHabitIds = await SupabaseService.instance
              .fetchTodayCompletedHabitIds(userId);
        }
      }
    } catch (e) {
      debugPrint('Error cargando datos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Maneja el toggle de completación de un hábito.
  Future<void> _handleToggleHabit(String habitId, bool isCompleted) async {
    // Optimistic UI update
    setState(() {
      if (isCompleted) {
        _completedHabitIds.add(habitId);
      } else {
        _completedHabitIds.remove(habitId);
      }
    });

    try {
      final actuallyCompleted =
          await SupabaseService.instance.toggleHabitCompletion(habitId);
      if (mounted && actuallyCompleted != isCompleted) {
        // Revertir si el servidor devolvió un estado diferente
        setState(() {
          if (actuallyCompleted) {
            _completedHabitIds.add(habitId);
          } else {
            _completedHabitIds.remove(habitId);
          }
        });
      }
    } catch (e) {
      // Revertir el cambio optimista
      if (mounted) {
        setState(() {
          if (isCompleted) {
            _completedHabitIds.remove(habitId);
          } else {
            _completedHabitIds.add(habitId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  /// Maneja el cierre de sesión.
  void _handleLogout() {
    setState(() {
      _currentUser = null;
      _habits = [];
      _completedHabitIds = {};
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Loading
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    // Auth
    if (_currentUser == null) {
      return AuthScreen(onLoginSuccess: (user) {
        setState(() {
          _currentUser = user;
        });
        _loadData();
      });
    }

    // Main app
    final screens = [
      DashboardTab(
        user: _currentUser!,
        habits: _habits,
        onRefresh: _loadData,
        completedHabitIds: _completedHabitIds,
        onToggleHabit: _handleToggleHabit,
      ),
      StatsTab(
        user: _currentUser!,
        habits: _habits,
        completedHabitIds: _completedHabitIds,
      ),
      ProfileTab(
        user: _currentUser!,
        onLogout: _handleLogout,
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: const Color(0xFF141724),
        indicatorColor: AppTheme.primary.withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle, color: AppTheme.primary),
            label: 'Mi Día',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: AppTheme.primary),
            label: 'Estadísticas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primary),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
