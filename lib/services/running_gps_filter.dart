import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/running_settings.dart';
import '../models/running_track_point.dart';

class RunningGpsFilter {
  final RunningSettings settings;
  RunningTrackPoint? _lastAccepted;
  _Kalman1d? _latFilter;
  _Kalman1d? _lngFilter;

  RunningGpsFilter(this.settings);

  RunningTrackPoint? accept(Position position) {
    final timestamp = position.timestamp;
    if (position.accuracy <= 0 ||
        position.accuracy > settings.maxAccuracyMeters) {
      return null;
    }
    if (timestamp.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      return null;
    }

    final raw = RunningTrackPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: position.speed.isFinite ? max(0, position.speed) : 0,
      altitude: position.altitude,
      timestamp: timestamp,
    );

    final previous = _lastAccepted;
    if (previous != null) {
      final seconds =
          raw.timestamp.difference(previous.timestamp).inMilliseconds / 1000;
      if (seconds <= 0) return null;

      final distance = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        raw.latitude,
        raw.longitude,
      );
      final segmentSpeed = distance / seconds;
      if (segmentSpeed > settings.maxHumanSpeedMps) return null;
    }

    _latFilter ??= _Kalman1d(raw.latitude, raw.accuracy);
    _lngFilter ??= _Kalman1d(raw.longitude, raw.accuracy);
    final smoothed = RunningTrackPoint(
      latitude: _latFilter!.filter(raw.latitude, raw.accuracy),
      longitude: _lngFilter!.filter(raw.longitude, raw.accuracy),
      accuracy: raw.accuracy,
      speed: raw.speed,
      altitude: raw.altitude,
      timestamp: raw.timestamp,
    );
    _lastAccepted = smoothed;
    return smoothed;
  }
}

class _Kalman1d {
  double _estimate;
  double _error;
  static const _processNoise = 0.000001;

  _Kalman1d(this._estimate, double initialAccuracy)
    : _error = max(initialAccuracy, 1);

  double filter(double measurement, double accuracy) {
    _error += _processNoise;
    final measurementNoise = max(accuracy, 1);
    final gain = _error / (_error + measurementNoise);
    _estimate += gain * (measurement - _estimate);
    _error = (1 - gain) * _error;
    return _estimate;
  }
}
