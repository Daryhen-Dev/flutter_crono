import 'package:geolocator/geolocator.dart';
import '../models/running_track_point.dart';

class RunningMetrics {
  RunningMetrics._();

  static double routeDistance(List<RunningTrackPoint> points) {
    if (points.length < 2) return 0;
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += distance(points[i - 1], points[i]);
    }
    return total;
  }

  static double distance(RunningTrackPoint a, RunningTrackPoint b) {
    return Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }

  static int? paceSecondsPerKm(double meters, int seconds) {
    if (meters <= 0 || seconds <= 0) return null;
    return (seconds / (meters / 1000)).round();
  }

  static int? windowPaceSecondsPerKm(
    List<RunningTrackPoint> points,
    double windowMeters,
  ) {
    if (points.length < 2) return null;
    var distanceMeters = 0.0;
    final end = points.last;
    var start = points.first;

    for (var i = points.length - 1; i > 0; i--) {
      distanceMeters += distance(points[i - 1], points[i]);
      start = points[i - 1];
      if (distanceMeters >= windowMeters) break;
    }

    final seconds = end.timestamp.difference(start.timestamp).inSeconds;
    return paceSecondsPerKm(distanceMeters, seconds);
  }
}
