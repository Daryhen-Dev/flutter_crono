import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/preset.dart';
import '../../../models/timer_type.dart';

class PresetTile extends StatelessWidget {
  final Preset preset;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PresetTile({
    super.key,
    required this.preset,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    switch (preset.type) {
      case TimerType.tabata:
        color = AppColors.work;
        icon = Icons.flash_on;
      case TimerType.classic:
        color = AppColors.rest;
        icon = Icons.loop;
      case TimerType.personalizado:
        color = AppColors.preparation;
        icon = Icons.tune;
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(preset.name),
        subtitle: Text(preset.type.displayName),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.textDim),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
