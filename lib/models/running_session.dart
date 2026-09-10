import 'running_goal.dart';
import 'running_pause_event.dart';
import 'running_track_point.dart';

class RunningSession {
  final String id;
  final DateTime startedAt;
  final DateTime completedAt;
  final int elapsedSeconds;
  final int movingSeconds;
  final double distanceMeters;
  final double averageSpeedMps;
  final int? averagePaceSecondsPerKm;
  final List<RunningTrackPoint> route;
  final List<RunningPauseEvent> pauses;
  final RunningGoal? goal;
  final bool? goalReached;

  const RunningSession({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.elapsedSeconds,
    required this.movingSeconds,
    required this.distanceMeters,
    required this.averageSpeedMps,
    required this.averagePaceSecondsPerKm,
    required this.route,
    required this.pauses,
    this.goal,
    this.goalReached,
  });

  double get distanceKm => distanceMeters / 1000;

  RunningSession copyWith({RunningGoal? goal, bool? goalReached}) {
    return RunningSession(
      id: id,
      startedAt: startedAt,
      completedAt: completedAt,
      elapsedSeconds: elapsedSeconds,
      movingSeconds: movingSeconds,
      distanceMeters: distanceMeters,
      averageSpeedMps: averageSpeedMps,
      averagePaceSecondsPerKm: averagePaceSecondsPerKm,
      route: route,
      pauses: pauses,
      goal: goal ?? this.goal,
      goalReached: goalReached ?? this.goalReached,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt.toIso8601String(),
    'elapsedSeconds': elapsedSeconds,
    'movingSeconds': movingSeconds,
    'distanceMeters': distanceMeters,
    'averageSpeedMps': averageSpeedMps,
    'averagePaceSecondsPerKm': averagePaceSecondsPerKm,
    'route': route.map((point) => point.toJson()).toList(),
    'pauses': pauses.map((pause) => pause.toJson()).toList(),
    'goal': goal?.toJson(),
    'goalReached': goalReached,
  };

  factory RunningSession.fromJson(Map<String, dynamic> json) {
    return RunningSession(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      elapsedSeconds: json['elapsedSeconds'] as int,
      movingSeconds: json['movingSeconds'] as int,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      averageSpeedMps: (json['averageSpeedMps'] as num).toDouble(),
      averagePaceSecondsPerKm: json['averagePaceSecondsPerKm'] as int?,
      route: (json['route'] as List<dynamic>)
          .map((e) => RunningTrackPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      pauses: (json['pauses'] as List<dynamic>)
          .map((e) => RunningPauseEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      goal: json['goal'] == null
          ? null
          : RunningGoal.fromJson(json['goal'] as Map<String, dynamic>),
      goalReached: json['goalReached'] as bool?,
    );
  }
}
