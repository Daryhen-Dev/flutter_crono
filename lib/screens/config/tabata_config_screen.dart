import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/timer_type.dart';
import '../../providers/tabata_config_provider.dart';
import '../../providers/presets_provider.dart';
import 'widgets/duration_field.dart';
import 'widgets/counter_field.dart';

class TabataConfigScreen extends StatelessWidget {
  const TabataConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TabataConfigProvider>();
    final config = provider.config;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabata'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: () => _savePreset(context),
            tooltip: 'Guardar rutina',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          DurationField(
            label: 'Preparación',
            totalSeconds: config.preparationSeconds,
            onChanged: provider.setPreparation,
          ),
          const Divider(),
          DurationField(
            label: 'Trabajo',
            totalSeconds: config.workSeconds,
            onChanged: provider.setWorkSeconds,
          ),
          DurationField(
            label: 'Descanso',
            totalSeconds: config.restSeconds,
            onChanged: provider.setRestSeconds,
          ),
          CounterField(
            label: 'Rondas',
            value: config.roundCount,
            onChanged: provider.setRoundCount,
          ),
          const Divider(),
          CounterField(
            label: 'Tabatas',
            value: config.tabataCount,
            onChanged: provider.setTabataCount,
          ),
          DurationField(
            label: 'Descanso Tabata',
            totalSeconds: config.tabataRestSeconds,
            onChanged: provider.setTabataRestSeconds,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push('/timer', extra: TimerType.tabata),
            child: const Text('INICIAR'),
          ),
        ],
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
              final config =
                  context.read<TabataConfigProvider>().config;
              context.read<PresetsProvider>().add(
                    name: name,
                    type: TimerType.tabata,
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
