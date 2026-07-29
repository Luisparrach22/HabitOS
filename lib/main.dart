// ──────────────────────────────────────────────
// main.dart — Punto de Entrada de HabitOS en Flutter (Clean Architecture)
// ──────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/theme/app_theme.dart';
import 'core/config/supabase_config.dart';
import 'core/network/supabase_service.dart';
import 'features/auth/data/user_model.dart';
import 'features/habits/data/habit_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const HabitOSApp());
}

class HabitOSApp extends StatelessWidget {
  const HabitOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainTabScreen(),
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;
  UserModel? _currentUser;
  List<HabitModel> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      if (session != null) {
        final userId = session.user.id.toLowerCase();
        final userMap = await SupabaseConfig.client.from('User').select().eq('id', userId).maybeSingle();
        if (userMap != null) {
          _currentUser = UserModel.fromJson(userMap);
          _habits = await SupabaseService.instance.fetchHabits(userId);
        }
      }
    } catch (e) {
      debugPrint('Error cargando datos en Flutter: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (_currentUser == null) {
      return AuthScreen(onLoginSuccess: (user) {
        setState(() {
          _currentUser = user;
        });
        _loadData();
      });
    }

    final screens = [
      DashboardTab(user: _currentUser!, habits: _habits, onRefresh: _loadData),
      StatsTab(user: _currentUser!, habits: _habits),
      ProfileTab(user: _currentUser!),
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

// ──────────────────────────────────────────────
// Pantalla de Autenticación
// ──────────────────────────────────────────────

class AuthScreen extends StatefulWidget {
  final Function(UserModel) onLoginSuccess;
  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();

      UserModel user;
      if (_isSignUp) {
        user = await SupabaseService.instance.signUp(email: email, password: password, name: name);
      } else {
        user = await SupabaseService.instance.signIn(email: email, password: password);
      }

      if (mounted) {
        widget.onLoginSuccess(user);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_sharp, size: 64, color: AppTheme.primary),
              const SizedBox(height: 16),
              Text(
                'HabitOS Flutter',
                style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 32),
              if (_isSignUp)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                ),
              if (_isSignUp) const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isSignUp ? 'Registrarse' : 'Iniciar Sesión'),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp ? '¿Ya tienes cuenta? Inicia sesión' : '¿No tienes cuenta? Regístrate'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Pestaña Dashboard (Mi Día)
// ──────────────────────────────────────────────

class DashboardTab extends StatelessWidget {
  final UserModel user;
  final List<HabitModel> habits;
  final VoidCallback onRefresh;

  const DashboardTab({super.key, required this.user, required this.habits, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HabitOS (Nivel ${user.level})'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Boss Battle Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.danger.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bug_report, size: 40, color: AppTheme.danger),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jefe Semanal: Monstruo Procrastinación',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        const LinearProgressIndicator(value: 0.7, color: AppTheme.danger, backgroundColor: Colors.white10),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Tus Hábitos Diarios', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (habits.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No tienes hábitos aún. ¡Crea uno!'))),
            ...habits.map((habit) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center, color: AppTheme.primary),
                    title: Text(habit.name),
                    subtitle: Text('Racha: ${habit.currentStreak} días'),
                    trailing: Checkbox(value: false, onChanged: (v) {}),
                  ),
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () {
          // Crear hábito
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Pestaña Estadísticas
// ──────────────────────────────────────────────

class StatsTab extends StatelessWidget {
  final UserModel user;
  final List<HabitModel> habits;

  const StatsTab({super.key, required this.user, required this.habits});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas & Consistencia')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, size: 64, color: AppTheme.primary),
            const SizedBox(height: 16),
            Text('Tasa de Consistencia Pro', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(user.isPro ? '🟢 Modo Pro Activo' : '🔴 Modo Gratis'),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Pestaña Perfil
// ──────────────────────────────────────────────

class ProfileTab extends StatelessWidget {
  final UserModel user;

  const ProfileTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: AppTheme.primary, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            Text(user.name ?? 'Usuario HabitOS', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user.email, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Experiencia (XP)'),
              trailing: Text('${user.totalXp} XP', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.verified_user, color: AppTheme.primary),
              title: const Text('Estado de la Cuenta'),
              trailing: Text(user.isPro ? 'PRO 👑' : 'GRATIS', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
