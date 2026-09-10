import 'package:flutter/material.dart';
import '../../models/running_session.dart';
import 'running_formatters.dart';
import 'widgets/running_route_map.dart';

class RunningRouteDetailScreen extends StatelessWidget {
  final RunningSession session;

  const RunningRouteDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ruta'), centerTitle: true),
      body: Column(
        children: [
          Expanded(child: RunningRouteMap(points: session.route)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(RunningFormatters.distance(session.distanceMeters)),
                Text(RunningFormatters.pace(session.averagePaceSecondsPerKm)),
                Text('${session.route.length} puntos'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
