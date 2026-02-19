import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/timer_state.dart';
import '../../../models/timer_phase.dart';

class CyberGridSkin extends StatelessWidget {
  final TimerState timerState;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const CyberGridSkin({
    super.key,
    required this.timerState,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final phaseColor = timerState.phase.color;
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
                  child: _CyberInfoBox(
                    label: 'RONDA',
                    value:
                        '${timerState.currentRound}/${timerState.totalRounds}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _CyberInfoBox(
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
                      child: _CyberInfoBox(
                        label: 'TABATA',
                        value:
                            '${timerState.currentTabata}/${timerState.totalTabatas}',
                      ),
                    ),
                  if (showTabatas && showSegments) const SizedBox(width: 12),
                  if (showSegments)
                    Expanded(
                      flex: 3,
                      child: _CyberInfoBox(
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
          // Timer container — fills available space
          Expanded(
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: CyberColors.background.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CyberColors.cyan, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: CyberColors.cyan.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
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
                        color: CyberColors.cyan.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Time display
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      timerState.formattedTime,
                      style: const TextStyle(
                        color: CyberColors.cyan,
                        fontSize: 88,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'monospace',
                        letterSpacing: 8,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 12,
                      child: LinearProgressIndicator(
                        value: timerState.progress,
                        backgroundColor:
                            CyberColors.cyan.withValues(alpha: 0.15),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(phaseColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Control buttons
          isFinished
              ? _CyberButton(
                  icon: Icons.check,
                  label: 'FINALIZAR',
                  onTap: onStop,
                )
              : Row(
                  children: [
                    Expanded(
                      child: _CyberButton(
                        icon: Icons.stop,
                        label: 'PARAR',
                        onTap: onStop,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _CyberButton(
                        icon: timerState.isRunning
                            ? Icons.pause
                            : Icons.play_arrow,
                        label: timerState.isRunning ? 'PAUSA' : 'REANUDAR',
                        onTap: timerState.isRunning ? onPause : onResume,
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

class _CyberInfoBox extends StatelessWidget {
  final String label;
  final String value;

  const _CyberInfoBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CyberColors.cyan.withValues(alpha: 0.3),
        ),
        color: CyberColors.background.withValues(alpha: 0.6),
        boxShadow: [
          BoxShadow(
            color: CyberColors.cyan.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: CyberColors.cyan.withValues(alpha: 0.5),
              fontSize: 11,
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
                color: CyberColors.cyan,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CyberButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CyberButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CyberColors.cyan, width: 1.5),
          color: CyberColors.cyan.withValues(alpha: 0.08),
          boxShadow: [
            BoxShadow(
              color: CyberColors.cyan.withValues(alpha: 0.15),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: CyberColors.cyan, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: CyberColors.cyan,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
