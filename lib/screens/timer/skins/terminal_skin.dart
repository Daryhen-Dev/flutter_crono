import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/timer_state.dart';
import '../../../models/timer_phase.dart';

class TerminalSkin extends StatelessWidget {
  final TimerState timerState;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const TerminalSkin({
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
    final isFinished = timerState.phase == TimerPhase.finished;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Top info boxes
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: _InfoBox(
                    label: 'RONDA',
                    value: '${timerState.currentRound}/${timerState.totalRounds}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _InfoBox(
                    label: 'ESTADO',
                    value: timerState.phase.displayName.toUpperCase(),
                  ),
                ),
              ],
            ),
          ),
          if (showTabatas || showSegments) ...[
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showTabatas)
                    Expanded(
                      flex: 2,
                      child: _InfoBox(
                        label: 'TABATA',
                        value:
                            '${timerState.currentTabata}/${timerState.totalTabatas}',
                      ),
                    ),
                  if (showTabatas && showSegments) const SizedBox(width: 12),
                  if (showSegments)
                    Expanded(
                      flex: 3,
                      child: _InfoBox(
                        label: 'BLOQUE',
                        value:
                            '${timerState.currentSegment}/${timerState.totalSegments}',
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Main timer container
          Expanded(
            child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: TerminalColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: TerminalColors.green.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'TIEMPO RESTANTE',
                    style: TextStyle(
                      color: TerminalColors.green.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Time display
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    timerState.formattedTime,
                    maxLines: 1,
                    style: const TextStyle(
                      color: TerminalColors.green,
                      fontSize: 72,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'monospace',
                      letterSpacing: 6,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Dotted progress bar
                _DottedProgressBar(
                  progress: timerState.progress,
                  color: timerState.phase.color,
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 24),
          // Buttons
          isFinished
              ? _TerminalButton(
                  label: '[FINALIZAR]',
                  onTap: onStop,
                  filled: true,
                )
              : Row(
                  children: [
                    Expanded(
                      child: _TerminalButton(
                        label: timerState.isRunning
                            ? '[PAUSA]'
                            : '[REANUDAR]',
                        onTap: timerState.isRunning ? onPause : onResume,
                        filled: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _TerminalButton(
                        label: '[PARAR]',
                        onTap: onStop,
                        filled: false,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: TerminalColors.green.withValues(alpha: 0.35),
        ),
        color: TerminalColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: TerminalColors.green.withValues(alpha: 0.5),
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: TerminalColors.green,
                fontSize: 26,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TerminalButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _TerminalButton({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: filled
              ? TerminalColors.green.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: TerminalColors.green,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: TerminalColors.green,
            fontSize: 16,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _DottedProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _DottedProgressBar({
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dotSize = 6.0;
        const dotSpacing = 4.0;
        final totalWidth = constraints.maxWidth;
        final dotCount =
            (totalWidth / (dotSize + dotSpacing)).floor();
        final filledCount = (dotCount * progress).round();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(dotCount, (i) {
            final isFilled = i < filledCount;
            return Padding(
              padding: EdgeInsets.only(
                right: i < dotCount - 1 ? dotSpacing : 0,
              ),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: isFilled
                      ? color
                      : TerminalColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
