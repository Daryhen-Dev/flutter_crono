import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/timer_type.dart';
import '../../models/custom_config.dart';
import '../../providers/custom_config_provider.dart';
import '../../providers/presets_provider.dart';
import 'widgets/duration_field.dart';
import 'widgets/counter_field.dart';

class CustomConfigScreen extends StatelessWidget {
  const CustomConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomConfigProvider>();
    final segments = provider.segments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: segments.isEmpty ? null : () => _savePreset(context),
            tooltip: 'Guardar rutina',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          DurationField(
            label: 'Descanso entre bloques',
            totalSeconds: provider.restBetweenSeconds,
            onChanged: provider.setRestBetween,
          ),
          DurationField(
            label: 'Preparación',
            totalSeconds: provider.preparationSeconds,
            onChanged: provider.setPreparation,
          ),
          const Divider(),
          const SizedBox(height: 8),
          ...List.generate(segments.length, (index) {
            final segment = segments[index];
            return _SegmentCard(
              index: index,
              segment: segment,
              onUpdate: (updated) => provider.updateSegment(index, updated),
              onRemove: () => provider.removeSegment(index),
            );
          }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showAddSegmentDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Agregar bloque'),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: segments.isEmpty
                ? null
                : () => context.push('/timer', extra: TimerType.personalizado),
            child: const Text('INICIAR'),
          ),
        ],
      ),
    );
  }

  void _showAddSegmentDialog(BuildContext context) {
    final provider = context.read<CustomConfigProvider>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text('Tipo de bloque',
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.loop, color: AppColors.rest),
              title: const Text('Clásico'),
              subtitle: const Text('Trabajo → Descanso × Rondas'),
              onTap: () {
                provider.addSegment(const CustomSegment(type: TimerType.classic));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_on, color: AppColors.work),
              title: const Text('Tabata'),
              subtitle: const Text('20s trabajo / 10s descanso × 8'),
              onTap: () {
                provider.addSegment(const CustomSegment(
                  type: TimerType.tabata,
                  workSeconds: 20,
                  restSeconds: 10,
                  roundCount: 8,
                ));
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _savePreset(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Guardar rutina'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la rutina'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final config = context.read<CustomConfigProvider>().config;
              context.read<PresetsProvider>().add(
                    name: name,
                    type: TimerType.personalizado,
                    config: config.toJson(),
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rutina guardada')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _SegmentCard extends StatelessWidget {
  final int index;
  final CustomSegment segment;
  final ValueChanged<CustomSegment> onUpdate;
  final VoidCallback onRemove;

  const _SegmentCard({
    required this.index,
    required this.segment,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isClassic = segment.type == TimerType.classic;
    final color = isClassic ? AppColors.rest : AppColors.work;
    final icon = isClassic ? Icons.loop : Icons.flash_on;
    final label = isClassic ? 'Clásico' : 'Tabata';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(label,
                      style: TextStyle(color: color, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Text('Bloque ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DurationField(
              label: 'Trabajo',
              totalSeconds: segment.workSeconds,
              onChanged: (v) => onUpdate(segment.copyWith(workSeconds: v)),
            ),
            DurationField(
              label: 'Descanso',
              totalSeconds: segment.restSeconds,
              onChanged: (v) => onUpdate(segment.copyWith(restSeconds: v)),
            ),
            CounterField(
              label: 'Rondas',
              value: segment.roundCount,
              onChanged: (v) =>
                  onUpdate(segment.copyWith(roundCount: v.clamp(1, 99))),
            ),
          ],
        ),
      ),
    );
  }
}
