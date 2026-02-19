import 'package:flutter/material.dart';
import '../../../models/timer_state.dart';
import '../../../models/timer_phase.dart';
import '../widgets/timer_ring.dart';
import '../widgets/phase_label.dart';
import '../widgets/round_indicator.dart';
import '../widgets/control_buttons.dart';

class ClassicSkin extends StatelessWidget {
  final TimerState timerState;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const ClassicSkin({
    super.key,
    required this.timerState,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final showTabatas = timerState.totalTabatas > 0;
    final showSegments = timerState.totalSegments > 0;

    return Column(
      children: [
        const SizedBox(height: 24),
        PhaseLabel(phase: timerState.phase),
        const Spacer(),
        TimerRing(
          progress: timerState.progress,
          color: timerState.phase.color,
          child: Text(
            timerState.formattedTime,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const SizedBox(height: 24),
        RoundIndicator(
          currentRound: timerState.currentRound,
          totalRounds: timerState.totalRounds,
          currentTabata: showTabatas ? timerState.currentTabata : null,
          totalTabatas: showTabatas ? timerState.totalTabatas : null,
          currentSegment: showSegments ? timerState.currentSegment : null,
          totalSegments: showSegments ? timerState.totalSegments : null,
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ControlButtons(
            isRunning: timerState.isRunning,
            isPaused: timerState.isPaused,
            isFinished: timerState.phase == TimerPhase.finished,
            onPause: onPause,
            onResume: onResume,
            onStop: onStop,
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
