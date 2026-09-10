import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/running_session.dart';
import '../../providers/running_history_provider.dart';
import 'running_formatters.dart';

class RunningHistoryScreen extends StatelessWidget {
  const RunningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<RunningHistoryProvider>().sessions;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial Running'), centerTitle: true),
      body: sessions.isEmpty
          ? const Center(child: Text('Sin corridas guardadas'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _RunningSessionTile(session: sessions[index]),
            ),
    );
  }
}

class _RunningSessionTile extends StatelessWidget {
  final RunningSession session;

  const _RunningSessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final goalText = session.goal == null
        ? null
        : '${RunningFormatters.goal(session.goal!)} · ${RunningFormatters.goalResult(session.goalReached)}';

    return ListTile(
      onTap: () => context.push('/running/route', extra: session),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      tileColor: AppColors.surface,
      leading: Icon(
        session.goalReached == true
            ? Icons.emoji_events_outlined
            : Icons.directions_run,
        color: session.goalReached == false ? AppColors.rest : AppColors.accent,
      ),
      title: Text(RunningFormatters.distance(session.distanceMeters)),
      subtitle: Text(
        [
          '${RunningFormatters.date(session.completedAt)} · ${RunningFormatters.pace(session.averagePaceSecondsPerKm)}',
          if (goalText != null) goalText,
        ].join('\n'),
      ),
      isThreeLine: goalText != null,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
