import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final int totalSessions;
  final int totalSeconds;
  final int avgSeconds;

  const SummaryCard({
    super.key,
    required this.totalSessions,
    required this.totalSeconds,
    required this.avgSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _stat(context, Icons.fitness_center, '$totalSessions',
                'sesiones'),
            _stat(context, Icons.timer, _formatDuration(totalSeconds),
                'total'),
            _stat(context, Icons.bar_chart, _formatDuration(avgSeconds),
                'promedio'),
          ],
        ),
      ),
    );
  }

  Widget _stat(
      BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.textPrimary)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textDim)),
      ],
    );
  }

  String _formatDuration(int seconds) {
    if (seconds >= 3600) {
      final h = seconds ~/ 3600;
      final m = (seconds % 3600) ~/ 60;
      return '${h}h ${m}m';
    }
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}
