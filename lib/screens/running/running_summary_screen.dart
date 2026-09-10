import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/running_session.dart';
import 'running_formatters.dart';
import 'widgets/running_route_map.dart';
import 'widgets/running_stat_tile.dart';

class RunningSummaryScreen extends StatelessWidget {
  final RunningSession session;

  const RunningSummaryScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/running'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(
            height: 260,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: ColoredBox(
                color: AppColors.surface,
                child: RunningRouteMap(points: session.route),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (session.goal != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: session.goalReached == true
                      ? AppColors.accent
                      : AppColors.rest,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    session.goalReached == true
                        ? Icons.emoji_events_outlined
                        : Icons.flag_outlined,
                    color: session.goalReached == true
                        ? AppColors.accent
                        : AppColors.rest,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(RunningFormatters.goal(session.goal!)),
                        Text(RunningFormatters.goalResult(session.goalReached)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
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
                value: RunningFormatters.distance(session.distanceMeters),
                icon: Icons.route_outlined,
              ),
              RunningStatTile(
                label: 'Movimiento',
                value: RunningFormatters.duration(session.movingSeconds),
                icon: Icons.timer_outlined,
              ),
              RunningStatTile(
                label: 'Ritmo promedio',
                value: RunningFormatters.pace(session.averagePaceSecondsPerKm),
                icon: Icons.speed,
              ),
              RunningStatTile(
                label: 'Pausas',
                value: '${session.pauses.length}',
                icon: Icons.pause_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/running/route', extra: session),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Ver mapa completo'),
          ),
        ],
      ),
    );
  }
}
