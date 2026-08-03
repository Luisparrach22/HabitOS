// ──────────────────────────────────────────────
// dashboard_tab.dart — Pestaña Dashboard (Mi Día)
// ──────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/network/supabase_service.dart';
import '../../auth/data/user_model.dart';
import '../data/habit_model.dart';

class DashboardTab extends StatefulWidget {
  final UserModel user;
  final List<HabitModel> habits;
  final VoidCallback onRefresh;
  final Set<String> completedHabitIds;
  final Function(String habitId, bool isCompleted) onToggleHabit;

  const DashboardTab({
    super.key,
    required this.user,
    required this.habits,
    required this.onRefresh,
    required this.completedHabitIds,
    required this.onToggleHabit,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Muestra el diálogo para crear un nuevo hábito.
  Future<void> _showCreateHabitDialog() async {
    _nameController.clear();
    _descriptionController.clear();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: Text(
          'Nuevo Hábito',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre del hábito',
                hintText: 'Ej: Meditar 10 min',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Ej: Meditación guiada por la mañana',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (confirmed == true && _nameController.text.trim().isNotEmpty) {
      final now = DateTime.now();
      final habit = HabitModel(
        id: '${now.microsecondsSinceEpoch.toRadixString(16)}-${widget.user.id.substring(0, 8)}',
        userId: widget.user.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        createdAt: now,
      );

      try {
        await SupabaseService.instance.saveHabit(habit);
        widget.onRefresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hábito "${habit.name}" creado'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      }
    }
  }

  /// Calcula el progreso diario (hábitos completados / total).
  double get _dailyProgress {
    if (widget.habits.isEmpty) return 0;
    return widget.completedHabitIds.length / widget.habits.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HabitOS (Nivel ${widget.user.level})'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Progreso diario
            _buildDailyProgressCard(),
            const SizedBox(height: 16),

            // Boss Battle Card
            _buildBossBattleCard(),
            const SizedBox(height: 24),

            // Header de hábitos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tus Hábitos Diarios',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.completedHabitIds.length}/${widget.habits.length}',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de hábitos (o estado vacío)
            if (widget.habits.isEmpty)
              _buildEmptyState()
            else
              ...widget.habits.map(_buildHabitCard),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: _showCreateHabitDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDailyProgressCard() {
    final percentage = (_dailyProgress * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.2),
            AppTheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso del Día',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _dailyProgress,
              minHeight: 8,
              color: AppTheme.primary,
              backgroundColor: Colors.white10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBossBattleCard() {
    return Container(
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
                Text(
                  'Jefe Semanal: Monstruo Procrastinación',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _dailyProgress,
                    color: AppTheme.danger,
                    backgroundColor: Colors.white10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.add_task_rounded,
              size: 64,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes hábitos aún',
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para crear tu primer hábito',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(HabitModel habit) {
    final isCompleted = widget.completedHabitIds.contains(habit.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted
              ? AppTheme.success.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          Icons.fitness_center,
          color: isCompleted ? AppTheme.success : AppTheme.primary,
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.white54 : Colors.white,
          ),
        ),
        subtitle: Text(
          'Racha: ${habit.currentStreak} días',
          style: TextStyle(
            color: isCompleted ? Colors.white30 : Colors.white54,
            fontSize: 12,
          ),
        ),
        trailing: Checkbox(
          value: isCompleted,
          activeColor: AppTheme.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onChanged: (value) {
            widget.onToggleHabit(habit.id, value ?? false);
          },
        ),
      ),
    );
  }
}
