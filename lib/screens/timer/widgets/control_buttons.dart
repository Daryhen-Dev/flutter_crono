import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ControlButtons extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;
  final bool isFinished;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const ControlButtons({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.isFinished,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    if (isFinished) {
      return ElevatedButton.icon(
        onPressed: onStop,
        icon: const Icon(Icons.check),
        label: const Text('FINALIZAR'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stop
        SizedBox(
          width: 64,
          height: 64,
          child: ElevatedButton(
            onPressed: onStop,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: const Icon(Icons.stop, size: 28),
          ),
        ),
        const SizedBox(width: 24),
        // Play / Pause
        SizedBox(
          width: 80,
          height: 80,
          child: ElevatedButton(
            onPressed: isRunning ? onPause : onResume,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: Icon(
              isRunning ? Icons.pause : Icons.play_arrow,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }
}
