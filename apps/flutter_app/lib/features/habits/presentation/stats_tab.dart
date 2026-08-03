// ──────────────────────────────────────────────
// stats_tab.dart — Pestaña de Estadísticas y Consistencia
// ──────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_theme.dart';
import '../../auth/data/user_model.dart';
import '../data/habit_model.dart';

class StatsTab extends StatelessWidget {
  final UserModel user;
  final List<HabitModel> habits;
  final Set<String> completedHabitIds;

  const StatsTab({
    super.key,
    required this.user,
    required this.habits,
    required this.completedHabitIds,
  });

  @override
  Widget build(BuildContext context) {
    final totalHabits = habits.length;
    final totalCompleted = completedHabitIds.length;
    final consistency = totalHabits > 0
        ? ((totalCompleted / totalHabits) * 100).toInt()
        : 0;
    final bestStreak = habits.isNotEmpty
        ? habits.map((h) => h.maxStreak).reduce((a, b) => a > b ? a : b)
        : 0;
    final currentStreakSum =
        habits.fold<int>(0, (sum, h) => sum + h.currentStreak);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas & Consistencia')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Pro / Gratis
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: user.isPro
                  ? const LinearGradient(
                      colors: [Color(0xFF6D28D9), Color(0xFFDB2777)],
                    )
                  : null,
              color: user.isPro ? null : AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  user.isPro ? Icons.workspace_premium : Icons.lock_outline,
                  size: 32,
                  color: user.isPro ? Colors.white : Colors.white54,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.isPro ? 'Modo Pro Activo' : 'Modo Gratis',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user.isPro
                            ? 'Estadísticas avanzadas desbloqueadas'
                            : 'Actualiza a Pro para ver estadísticas avanzadas',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Grid de estadísticas
          Text(
            'Resumen del Día',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppTheme.success,
                  label: 'Completados Hoy',
                  value: '$totalCompleted/$totalHabits',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.percent,
                  iconColor: AppTheme.primary,
                  label: 'Consistencia',
                  value: '$consistency%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  iconColor: AppTheme.warning,
                  label: 'Mejor Racha',
                  value: '$bestStreak días',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.bolt,
                  iconColor: AppTheme.secondary,
                  label: 'Rachas Activas',
                  value: '$currentStreakSum',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star_rounded,
                  iconColor: Colors.amber,
                  label: 'XP Total',
                  value: '${user.totalXp}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: AppTheme.success,
                  label: 'Nivel',
                  value: '${user.level}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lista de rachas por hábito
          Text(
            'Rachas por Hábito',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (habits.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Crea hábitos para ver tus estadísticas',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            ...habits.map((habit) => _buildStreakTile(habit)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakTile(HabitModel habit) {
    final isCompleted = completedHabitIds.contains(habit.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? AppTheme.success : Colors.white24,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habit.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department,
                      size: 14, color: AppTheme.warning),
                  const SizedBox(width: 4),
                  Text(
                    '${habit.currentStreak}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warning,
                    ),
                  ),
                ],
              ),
              Text(
                'Mejor: ${habit.maxStreak}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
