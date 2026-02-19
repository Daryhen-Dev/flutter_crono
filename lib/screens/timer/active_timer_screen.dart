import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/timer_type.dart';
import '../../models/timer_phase.dart';
import '../../models/timer_skin.dart';
import '../../providers/timer_provider.dart';
import '../../providers/classic_config_provider.dart';
import '../../providers/tabata_config_provider.dart';
import '../../providers/custom_config_provider.dart';
import '../../providers/audio_settings_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/skin_provider.dart';
import 'skins/classic_skin.dart';
import 'skins/cyber_grid_skin.dart';
import 'skins/terminal_skin.dart';

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
      final audioSettings = context.read<AudioSettingsProvider>().settings;
      timerProvider.updateAudioSettings(audioSettings);
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
    final skin = context.watch<SkinProvider>().skin;

    void onStop() {
      final timerProvider = context.read<TimerProvider>();
      final record = timerProvider.lastCompletedRecord;
      if (record != null) {
        context.read<HistoryProvider>().add(record);
      }
      timerProvider.stop();
      context.pop();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: switch (skin) {
            TimerSkin.classic => ClassicSkin(
                timerState: timerState,
                onPause: context.read<TimerProvider>().pause,
                onResume: context.read<TimerProvider>().resume,
                onStop: onStop,
              ),
            TimerSkin.cyberGrid => CyberGridSkin(
                timerState: timerState,
                onPause: context.read<TimerProvider>().pause,
                onResume: context.read<TimerProvider>().resume,
                onStop: onStop,
              ),
            TimerSkin.terminal => TerminalSkin(
                timerState: timerState,
                onPause: context.read<TimerProvider>().pause,
                onResume: context.read<TimerProvider>().resume,
                onStop: onStop,
              ),
          },
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
