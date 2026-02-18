import 'package:flutter/material.dart';
import '../../../models/timer_phase.dart';

class PhaseLabel extends StatelessWidget {
  final TimerPhase phase;

  const PhaseLabel({super.key, required this.phase});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: phase.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        phase.displayName.toUpperCase(),
        style: TextStyle(
          color: phase.color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
