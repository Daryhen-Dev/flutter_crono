import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/running_track_point.dart';

class RunningRouteMap extends StatelessWidget {
  final List<RunningTrackPoint> points;

  const RunningRouteMap({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('Sin puntos GPS para mostrar'));
    }

    final route = points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final center = route[route.length ~/ 2];

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: route.length > 1 ? 16 : 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.flutter_crono',
        ),
        PolylineLayer(
          polylines: [
            Polyline(points: route, color: AppColors.accent, strokeWidth: 5),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: route.first,
              width: 36,
              height: 36,
              child: const Icon(Icons.flag, color: AppColors.rest),
            ),
            Marker(
              point: route.last,
              width: 36,
              height: 36,
              child: const Icon(
                Icons.location_on,
                color: AppColors.preparation,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
