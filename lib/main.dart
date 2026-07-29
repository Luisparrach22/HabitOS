// ──────────────────────────────────────────────
// main.dart — Punto de Entrada de HabitOS en Flutter
// ──────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/supabase_config.dart';
import 'services/supabase_service.dart';
import 'models/user_model.dart';
import 'models/habit_model.dart';

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F111A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFFEC4899),
          surface: Color(0xFF1A1D2B),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
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
        indicatorColor: const Color(0xFF8B5CF6).withOpacity(0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle, color: Color(0xFF8B5CF6)),
            label: 'Mi Día',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF8B5CF6)),
            label: 'Estadísticas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF8B5CF6)),
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

      widget.onLoginSuccess(user);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
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
              const Icon(Icons.verified_sharp, size: 64, color: Color(0xFF8B5CF6)),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                color: const Color(0xFF181B2B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bug_report, size: 40, color: Color(0xFFFF3B30)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jefe Semanal: Monstruo Procrastinación',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(value: 0.7, color: const Color(0xFFFF3B30), backgroundColor: Colors.white10),
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
                    leading: const Icon(Icons.fitness_center, color: Color(0xFF8B5CF6)),
                    title: Text(habit.name),
                    subtitle: Text('Racha: ${habit.currentStreak} días'),
                    trailing: Checkbox(value: false, onChanged: (v) {}),
                  ),
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5CF6),
        onPressed: () {
          // Abrir dialogo crear habito
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
            const Icon(Icons.analytics, size: 64, color: Color(0xFF8B5CF6)),
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
            const CircleAvatar(radius: 40, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            Text(user.name ?? 'Usuario HabitOS', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user.email, style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Experiencia (XP)'),
              trailing: Text('${user.totalXp} XP', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.verified_user, color: Color(0xFF8B5CF6)),
              title: const Text('Estado de la Cuenta'),
              trailing: Text(user.isPro ? 'PRO 👑' : 'GRATIS', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
