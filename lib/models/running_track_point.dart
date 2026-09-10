class RunningTrackPoint {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double speed;
  final double altitude;
  final DateTime timestamp;

  const RunningTrackPoint({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.altitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'speed': speed,
    'altitude': altitude,
    'timestamp': timestamp.toIso8601String(),
  };

  factory RunningTrackPoint.fromJson(Map<String, dynamic> json) {
    return RunningTrackPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
