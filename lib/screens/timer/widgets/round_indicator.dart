import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RoundIndicator extends StatelessWidget {
  final int currentRound;
  final int totalRounds;
  final int? currentTabata;
  final int? totalTabatas;
  final int? currentSegment;
  final int? totalSegments;

  const RoundIndicator({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    this.currentTabata,
    this.totalTabatas,
    this.currentSegment,
    this.totalSegments,
  });

  @override
  Widget build(BuildContext context) {
    final showTabata =
        totalTabatas != null && totalTabatas! > 0 && currentTabata != null;
    final showSegment =
        totalSegments != null && totalSegments! > 0 && currentSegment != null;
    return Column(
      children: [
        Text(
          'Ronda $currentRound / $totalRounds',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (showTabata) ...[
          const SizedBox(height: 4),
          Text(
            'Tabata $currentTabata / $totalTabatas',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.tabataRest),
          ),
        ],
        if (showSegment) ...[
          const SizedBox(height: 4),
          Text(
            'Bloque $currentSegment / $totalSegments',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.preparation),
          ),
        ],
      ],
    );
  }
}
