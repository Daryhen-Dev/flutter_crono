import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DurationField extends StatelessWidget {
  final String label;
  final int totalSeconds;
  final ValueChanged<int> onChanged;

  const DurationField({
    super.key,
    required this.label,
    required this.totalSeconds,
    required this.onChanged,
  });

  String get _formatted {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _adjust(int delta) {
    final next = (totalSeconds + delta).clamp(1, 5999);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          IconButton(
            onPressed: () => _adjust(-5),
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.textSecondary,
          ),
          SizedBox(
            width: 72,
            child: Text(
              _formatted,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
            ),
          ),
          IconButton(
            onPressed: () => _adjust(5),
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
