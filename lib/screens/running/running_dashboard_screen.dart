import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/running_goal.dart';
import '../../models/running_session.dart';
import '../../providers/running_history_provider.dart';
import 'running_formatters.dart';
import 'widgets/running_month_calendar.dart';
import 'widgets/running_stat_tile.dart';

class RunningDashboardScreen extends StatelessWidget {
  const RunningDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<RunningHistoryProvider>();
    final sessions = history.sessions;
    final totalDistance = history.totalDistanceMeters;
    final totalSeconds = sessions.fold<int>(
      0,
      (sum, s) => sum + s.movingSeconds,
    );
    final last = sessions.isNotEmpty ? sessions.first : null;
    final weeklyGoal = history.latestWeeklyGoalSession;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Running'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/running/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.28),
                    AppColors.rest.withValues(alpha: 0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salí a correr',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GPS con filtro de precisión, suavizado y auto-pausa.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: () => context.push('/running/active'),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Iniciar corrida'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                RunningStatTile(
                  label: 'Distancia total',
                  value: RunningFormatters.distance(totalDistance),
                  icon: Icons.route_outlined,
                ),
                RunningStatTile(
                  label: 'Tiempo en movimiento',
                  value: RunningFormatters.duration(totalSeconds),
                  icon: Icons.timer_outlined,
                ),
                RunningStatTile(
                  label: 'Racha actual',
                  value: '${history.currentStreakDays} dias',
                  icon: Icons.local_fire_department_outlined,
                ),
                RunningStatTile(
                  label: 'Sesiones',
                  value: '${history.completedSessions}',
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
            if (weeklyGoal != null) ...[
              const SizedBox(height: 18),
              _WeeklyGoalCard(session: weeklyGoal, history: history),
            ],
            const SizedBox(height: 18),
            RunningMonthCalendar(
              sessionDaysForMonth: history.sessionDaysInMonth,
            ),
            const SizedBox(height: 18),
            _ActionRow(
              icon: Icons.history,
              title: 'Historial de corridas',
              subtitle: '${sessions.length} sesiones guardadas',
              onTap: () => context.push('/running/history'),
            ),
            if (last != null) ...[
              const SizedBox(height: 12),
              _ActionRow(
                icon: Icons.map_outlined,
                title: 'Ultima ruta',
                subtitle:
                    '${RunningFormatters.distance(last.distanceMeters)} · ${RunningFormatters.pace(last.averagePaceSecondsPerKm)}',
                onTap: () => context.push('/running/route', extra: last),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeeklyGoalCard extends StatelessWidget {
  final RunningSession session;
  final RunningHistoryProvider history;

  const _WeeklyGoalCard({required this.session, required this.history});

  @override
  Widget build(BuildContext context) {
    final goal = session.goal;
    if (goal == null || goal.type != RunningGoalType.weeklyFrequency) {
      return const SizedBox.shrink();
    }

    final current = history.weeklyGoalProgress(session);
    final target = goal.targetWeeklySessions ?? 0;
    final progress = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final reached = current >= target && target > 0;

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
          Text('Meta semanal', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text(
            '$current / $target sesiones · ${reached ? 'alcanzada' : 'pendiente'}',
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      tileColor: AppColors.surface,
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
