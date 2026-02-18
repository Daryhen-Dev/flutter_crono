import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/workout_record.dart';
import 'workout_record_tile.dart';

class WorkoutDayGroup extends StatelessWidget {
  final String label;
  final List<WorkoutRecord> records;

  const WorkoutDayGroup({
    super.key,
    required this.label,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        ...records.map((r) => WorkoutRecordTile(record: r)),
      ],
    );
  }
}
