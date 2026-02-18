import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Icon(
                Icons.timer_outlined,
                size: 80,
                color: AppColors.accent,
              ),
              const SizedBox(height: 16),
              Text('CRONO', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Elige tu modo de entrenamiento',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              _ModeCard(
                title: 'Tabata',
                subtitle: 'Intervalos de alta intensidad',
                icon: Icons.flash_on,
                color: AppColors.work,
                onTap: () => context.push('/tabata/config'),
              ),
              const SizedBox(height: 16),
              _ModeCard(
                title: 'Clásico',
                subtitle: 'Rondas con descanso',
                icon: Icons.loop,
                color: AppColors.rest,
                onTap: () => context.push('/classic/config'),
              ),
              const SizedBox(height: 16),
              _ModeCard(
                title: 'Personalizado',
                subtitle: 'Mezcla opciones a tu gusto',
                icon: Icons.tune,
                color: AppColors.preparation,
                onTap: () => context.push('/custom/config'),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => context.push('/presets'),
                icon: const Icon(Icons.bookmark_outline),
                label: const Text('Rutinas guardadas'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/history'),
                icon: const Icon(Icons.history),
                label: const Text('Historial'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textDim),
            ],
          ),
        ),
      ),
    );
  }
}
