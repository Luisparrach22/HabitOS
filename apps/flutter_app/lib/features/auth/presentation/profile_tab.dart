// ──────────────────────────────────────────────
// profile_tab.dart — Pestaña de Perfil de Usuario
// ──────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/network/supabase_service.dart';
import '../data/user_model.dart';

class ProfileTab extends StatelessWidget {
  final UserModel user;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 16),

          // Avatar
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 2),
              ),
              child: const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF232740),
                child: Icon(Icons.person, size: 40, color: AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nombre y email
          Center(
            child: Text(
              user.name ?? 'Usuario HabitOS',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              user.email,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          const SizedBox(height: 8),

          // Badge Pro
          if (user.isPro)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PRO 👑',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 32),

          // Estadísticas rápidas
          _buildInfoTile(
            icon: Icons.star_rounded,
            iconColor: Colors.amber,
            title: 'Experiencia Total',
            trailing: '${user.totalXp} XP',
          ),
          _buildInfoTile(
            icon: Icons.trending_up_rounded,
            iconColor: AppTheme.success,
            title: 'Nivel Actual',
            trailing: 'Nivel ${user.level}',
          ),
          _buildInfoTile(
            icon: Icons.verified_user_rounded,
            iconColor: AppTheme.primary,
            title: 'Estado de Cuenta',
            trailing: user.isPro ? 'PRO' : 'GRATIS',
          ),
          _buildInfoTile(
            icon: Icons.access_time_rounded,
            iconColor: Colors.white54,
            title: 'Zona Horaria',
            trailing: user.timezone,
          ),

          const SizedBox(height: 32),

          // Botón cerrar sesión
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: AppTheme.danger),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: AppTheme.danger),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppTheme.cardBackground,
                    title: const Text('Cerrar Sesión'),
                    content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(color: AppTheme.danger),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await SupabaseService.instance.signOut();
                  onLogout();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        trailing: Text(
          trailing,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
