import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/timer_type.dart';

class TypeFilterChips extends StatelessWidget {
  final TimerType? selected;
  final ValueChanged<TimerType?> onChanged;

  const TypeFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _chip('Todos', selected == null, () => onChanged(null)),
        const SizedBox(width: 8),
        _chip('Tabata', selected == TimerType.tabata,
            () => onChanged(TimerType.tabata)),
        const SizedBox(width: 8),
        _chip('Clásico', selected == TimerType.classic,
            () => onChanged(TimerType.classic)),
        const SizedBox(width: 8),
        _chip('Personalizado', selected == TimerType.personalizado,
            () => onChanged(TimerType.personalizado)),
      ],
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.surfaceLight,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textPrimary : AppColors.textDim,
      ),
      backgroundColor: AppColors.surface,
      side: BorderSide.none,
      checkmarkColor: AppColors.accent,
    );
  }
}
