import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/workout_record.dart';
import '../../../models/timer_type.dart';

class WorkoutRecordTile extends StatelessWidget {
  final WorkoutRecord record;

  const WorkoutRecordTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    switch (record.type) {
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
    final hour =
        '${record.completedAt.hour.toString().padLeft(2, '0')}:${record.completedAt.minute.toString().padLeft(2, '0')}';

    return ListTile(
      dense: true,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 18,
        ),
      ),
      title: Text(record.type.displayName,
          style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(
        record.type == TimerType.personalizado
            ? '${record.tabatasCompleted} bloques'
            : '${record.roundsCompleted} rondas${record.tabatasCompleted > 0 ? ' · ${record.tabatasCompleted} tabatas' : ''}',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: AppColors.textDim),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(hour,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary)),
          Text(_formatDuration(record.totalSeconds),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.accent)),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}
