import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CounterField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const CounterField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (label.isNotEmpty)
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18)),
            ),
          if (label.isEmpty) const Spacer(),
          IconButton(
            onPressed:
                value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline, size: 28),
            color: AppColors.textSecondary,
          ),
          SizedBox(
            width: 56,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          IconButton(
            onPressed:
                value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline, size: 28),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
