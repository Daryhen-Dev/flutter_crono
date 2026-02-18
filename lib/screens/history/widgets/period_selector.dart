import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum PeriodType { week, month, year }

class PeriodSelector extends StatelessWidget {
  final PeriodType selected;
  final ValueChanged<PeriodType> onChanged;

  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: PeriodType.values.map((period) {
        final isSelected = period == selected;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(_label(period)),
            selected: isSelected,
            onSelected: (_) => onChanged(period),
            selectedColor: AppColors.accent,
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: AppColors.surface,
            side: BorderSide.none,
          ),
        );
      }).toList(),
    );
  }

  String _label(PeriodType period) {
    switch (period) {
      case PeriodType.week:
        return 'Semana';
      case PeriodType.month:
        return 'Mes';
      case PeriodType.year:
        return 'Año';
    }
  }
}
