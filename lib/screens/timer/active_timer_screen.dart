import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/timer_type.dart';
import '../../models/timer_phase.dart';
import '../../providers/timer_provider.dart';
import '../../providers/classic_config_provider.dart';
import '../../providers/tabata_config_provider.dart';
import '../../providers/custom_config_provider.dart';
import '../../providers/history_provider.dart';
import 'widgets/timer_ring.dart';
import 'widgets/phase_label.dart';
import 'widgets/round_indicator.dart';
import 'widgets/control_buttons.dart';

class ActiveTimerScreen extends StatefulWidget {
  final TimerType type;

  const ActiveTimerScreen({super.key, required this.type});

  @override
  State<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends State<ActiveTimerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerProvider = context.read<TimerProvider>();
      if (widget.type == TimerType.classic) {
        final config = context.read<ClassicConfigProvider>().config;
        timerProvider.startClassic(config);
      } else if (widget.type == TimerType.personalizado) {
        final config = context.read<CustomConfigProvider>().config;
        timerProvider.startCustom(config);
      } else {
        final config = context.read<TabataConfigProvider>().config;
        timerProvider.startTabata(config);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerState = context.watch<TimerProvider>().state;
    final showTabatas = timerState.totalTabatas > 0;
    final showSegments = timerState.totalSegments > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
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
                  onPause: context.read<TimerProvider>().pause,
                  onResume: context.read<TimerProvider>().resume,
                  onStop: () {
                    final timerProvider = context.read<TimerProvider>();
                    final record = timerProvider.lastCompletedRecord;
                    if (record != null) {
                      context.read<HistoryProvider>().add(record);
                    }
                    timerProvider.stop();
                    context.pop();
                  },
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    final timerProvider = context.read<TimerProvider>();
    if (timerProvider.state.phase == TimerPhase.finished ||
        timerProvider.state.phase == TimerPhase.idle) {
      timerProvider.stop();
      context.pop();
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salir del timer?'),
        content: const Text('El progreso se perderá.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              timerProvider.stop();
              context.pop();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
