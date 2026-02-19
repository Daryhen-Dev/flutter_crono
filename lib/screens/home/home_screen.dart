import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/timer_skin.dart';
import '../../providers/skin_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Top bar
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tip Tap Workout',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  _TopBarButton(
                    icon: Icons.music_note_outlined,
                    onTap: () => context.push('/audio-settings'),
                  ),
                  const SizedBox(width: 6),
                  _TopBarButton(
                    icon: Icons.palette_outlined,
                    onTap: () => _showSkinSelector(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Subtitle
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Elige tu entrenamiento',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 20),
              // Mode cards
              _ModeCard(
                title: 'Clásico',
                subtitle: 'Rondas con descanso',
                icon: Icons.loop,
                color: AppColors.rest,
                onTap: () => context.push('/classic/config'),
              ),
              const SizedBox(height: 12),
              _ModeCard(
                title: 'Tabata',
                subtitle: 'Intervalos de alta intensidad',
                icon: Icons.flash_on,
                color: AppColors.accent,
                onTap: () => context.push('/tabata/config'),
              ),
              const SizedBox(height: 12),
              _ModeCard(
                title: 'Personalizado',
                subtitle: 'Mezcla opciones a tu gusto',
                icon: Icons.tune,
                color: AppColors.preparation,
                onTap: () => context.push('/custom/config'),
              ),
              const Spacer(),
              // Bottom actions
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.bookmark_outline,
                      label: 'Rutinas',
                      onTap: () => context.push('/presets'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.history,
                      label: 'Historial',
                      onTap: () => context.push('/history'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showSkinSelector(BuildContext context) {
    final skinProvider = context.read<SkinProvider>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Apariencia del timer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...TimerSkin.values.map((skin) {
                final isSelected = skinProvider.skin == skin;
                return ListTile(
                  leading: Icon(
                    skin.icon,
                    color: isSelected ? AppColors.accent : null,
                  ),
                  title: Text(
                    skin.displayName,
                    style: TextStyle(
                      color: isSelected ? AppColors.accent : null,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.accent)
                      : null,
                  onTap: () {
                    skinProvider.skin = skin;
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopBarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: color,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
