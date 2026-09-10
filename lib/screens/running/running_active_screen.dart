import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/running_goal.dart';
import '../../models/running_settings.dart';
import '../../providers/running_history_provider.dart';
import '../../providers/running_provider.dart';
import '../../providers/running_settings_provider.dart';
import 'running_formatters.dart';
import 'widgets/running_route_map.dart';
import 'widgets/running_stat_tile.dart';

class RunningActiveScreen extends StatefulWidget {
  const RunningActiveScreen({super.key});

  @override
  State<RunningActiveScreen> createState() => _RunningActiveScreenState();
}

class _RunningActiveScreenState extends State<RunningActiveScreen> {
  RunningGoalType _goalType = RunningGoalType.distance;
  final _distanceController = TextEditingController(text: '5');
  final _timeController = TextEditingController(text: '30');
  final _weeklyController = TextEditingController(text: '3');

  @override
  void dispose() {
    _distanceController.dispose();
    _timeController.dispose();
    _weeklyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RunningProvider>();
    final settings = context.watch<RunningSettingsProvider>().settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Corrida activa'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(
              height: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: ColoredBox(
                  color: AppColors.surface,
                  child: RunningRouteMap(points: provider.route),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (provider.status == RunningStatus.permissionDenied)
              const Text(
                'Permiso de ubicacion denegado. Revisá ajustes del sistema.',
              ),
            if (provider.autoPaused)
              const Text(
                'Auto-pausa activa',
                style: TextStyle(color: AppColors.preparation),
              ),
            if (!provider.isActive &&
                provider.status != RunningStatus.acquiring) ...[
              const SizedBox(height: 8),
              _GoalSetupCard(
                goalType: _goalType,
                distanceController: _distanceController,
                timeController: _timeController,
                weeklyController: _weeklyController,
                onChanged: (value) => setState(() => _goalType = value),
              ),
            ],
            if (provider.goal != null) ...[
              const SizedBox(height: 8),
              _GoalProgressCard(provider: provider),
            ],
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                RunningStatTile(
                  label: 'Distancia',
                  value: RunningFormatters.distance(provider.distanceMeters),
                  icon: Icons.route_outlined,
                ),
                RunningStatTile(
                  label: 'Tiempo',
                  value: RunningFormatters.duration(provider.movingSeconds),
                  icon: Icons.timer_outlined,
                ),
                RunningStatTile(
                  label: 'Ritmo actual',
                  value: RunningFormatters.pace(
                    provider.currentPaceSecondsPerKm,
                  ),
                  icon: Icons.speed,
                ),
                RunningStatTile(
                  label: 'Ritmo promedio',
                  value: RunningFormatters.pace(
                    provider.averagePaceSecondsPerKm,
                  ),
                  icon: Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: provider.isActive
                        ? () => provider.isPaused
                              ? provider.resume()
                              : provider.pause()
                        : null,
                    child: Text(provider.isPaused ? 'Reanudar' : 'Pausar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: provider.status == RunningStatus.acquiring
                        ? null
                        : () => _mainAction(context, provider, settings),
                    child: Text(provider.isActive ? 'Finalizar' : 'Iniciar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mainAction(
    BuildContext context,
    RunningProvider provider,
    RunningSettings settings,
  ) async {
    if (!provider.isActive) {
      final goal = _buildGoal();
      if (goal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Definí una meta valida para iniciar.')),
        );
        return;
      }

      final weeklySessions = context
          .read<RunningHistoryProvider>()
          .sessionsInWeek(DateTime.now());
      await provider.start(
        settings,
        goal: goal,
        weeklySessionsBeforeStart: weeklySessions,
      );
      return;
    }
    final session = await provider.finish();
    if (session == null || !context.mounted) return;
    final savedSession = await context.read<RunningHistoryProvider>().add(
      session,
    );
    if (!context.mounted) return;
    context.go('/running/summary', extra: savedSession);
  }

  RunningGoal? _buildGoal() {
    return switch (_goalType) {
      RunningGoalType.distance => () {
        final km = double.tryParse(
          _distanceController.text.replaceAll(',', '.'),
        );
        return km == null || km <= 0 ? null : RunningGoal.distance(km * 1000);
      }(),
      RunningGoalType.time => () {
        final minutes = int.tryParse(_timeController.text);
        return minutes == null || minutes <= 0
            ? null
            : RunningGoal.time(minutes * 60);
      }(),
      RunningGoalType.weeklyFrequency => () {
        final sessions = int.tryParse(_weeklyController.text);
        return sessions == null || sessions <= 0
            ? null
            : RunningGoal.weeklyFrequency(sessions);
      }(),
    };
  }
}

class _GoalSetupCard extends StatelessWidget {
  final RunningGoalType goalType;
  final TextEditingController distanceController;
  final TextEditingController timeController;
  final TextEditingController weeklyController;
  final ValueChanged<RunningGoalType> onChanged;

  const _GoalSetupCard({
    required this.goalType,
    required this.distanceController,
    required this.timeController,
    required this.weeklyController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meta de la corrida',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton<RunningGoalType>(
            segments: const [
              ButtonSegment(
                value: RunningGoalType.distance,
                label: Text('Distancia'),
              ),
              ButtonSegment(value: RunningGoalType.time, label: Text('Tiempo')),
              ButtonSegment(
                value: RunningGoalType.weeklyFrequency,
                label: Text('Semana'),
              ),
            ],
            selected: {goalType},
            onSelectionChanged: (selected) => onChanged(selected.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: switch (goalType) {
              RunningGoalType.distance => distanceController,
              RunningGoalType.time => timeController,
              RunningGoalType.weeklyFrequency => weeklyController,
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: switch (goalType) {
                RunningGoalType.distance => 'Kilometros objetivo',
                RunningGoalType.time => 'Minutos en movimiento',
                RunningGoalType.weeklyFrequency => 'Sesiones por semana',
              },
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  final RunningProvider provider;

  const _GoalProgressCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final goal = provider.goal!;
    final value = provider.goalProgress;
    final detail = switch (goal.type) {
      RunningGoalType.distance =>
        '${RunningFormatters.distance(provider.distanceMeters)} / ${RunningFormatters.distance(goal.targetDistanceMeters ?? 0)}',
      RunningGoalType.time =>
        '${RunningFormatters.duration(provider.movingSeconds)} / ${RunningFormatters.duration(goal.targetDurationSeconds ?? 0)}',
      RunningGoalType.weeklyFrequency =>
        '${provider.weeklySessionsIncludingCurrent} / ${goal.targetWeeklySessions ?? 0} sesiones esta semana',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(RunningFormatters.goal(goal)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: value),
          const SizedBox(height: 8),
          Text('$detail · ${(value * 100).round()}%'),
        ],
      ),
    );
  }
}
