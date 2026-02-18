import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/timer_type.dart';
import '../../providers/presets_provider.dart';
import '../../providers/classic_config_provider.dart';
import '../../providers/tabata_config_provider.dart';
import '../../providers/custom_config_provider.dart';
import 'widgets/preset_tile.dart';

class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final presets = context.watch<PresetsProvider>().presets;

    return Scaffold(
      appBar: AppBar(title: const Text('Rutinas guardadas')),
      body: presets.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bookmark_border,
                      size: 64, color: AppColors.textDim),
                  const SizedBox(height: 16),
                  Text(
                    'Sin rutinas guardadas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: presets.length,
              itemBuilder: (context, i) {
                final preset = presets[i];
                return PresetTile(
                  preset: preset,
                  onTap: () {
                    if (preset.type == TimerType.classic) {
                      context
                          .read<ClassicConfigProvider>()
                          .loadConfig(preset.classicConfig!);
                      context.push('/classic/config');
                    } else if (preset.type == TimerType.personalizado) {
                      context
                          .read<CustomConfigProvider>()
                          .loadConfig(preset.customConfig!);
                      context.push('/custom/config');
                    } else {
                      context
                          .read<TabataConfigProvider>()
                          .loadConfig(preset.tabataConfig!);
                      context.push('/tabata/config');
                    }
                  },
                  onDelete: () =>
                      context.read<PresetsProvider>().remove(preset.id),
                );
              },
            ),
    );
  }
}
