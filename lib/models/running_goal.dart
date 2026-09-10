enum RunningGoalType { distance, time, weeklyFrequency }

class RunningGoal {
  final RunningGoalType type;
  final double? targetDistanceMeters;
  final int? targetDurationSeconds;
  final int? targetWeeklySessions;

  const RunningGoal.distance(double meters)
    : type = RunningGoalType.distance,
      targetDistanceMeters = meters,
      targetDurationSeconds = null,
      targetWeeklySessions = null;

  const RunningGoal.time(int seconds)
    : type = RunningGoalType.time,
      targetDistanceMeters = null,
      targetDurationSeconds = seconds,
      targetWeeklySessions = null;

  const RunningGoal.weeklyFrequency(int sessions)
    : type = RunningGoalType.weeklyFrequency,
      targetDistanceMeters = null,
      targetDurationSeconds = null,
      targetWeeklySessions = sessions;

  double progress({
    required double distanceMeters,
    required int movingSeconds,
    int weeklySessionsIncludingCurrent = 0,
  }) {
    final raw = switch (type) {
      RunningGoalType.distance =>
        targetDistanceMeters == null || targetDistanceMeters! <= 0
            ? 0.0
            : distanceMeters / targetDistanceMeters!,
      RunningGoalType.time =>
        targetDurationSeconds == null || targetDurationSeconds! <= 0
            ? 0.0
            : movingSeconds / targetDurationSeconds!,
      RunningGoalType.weeklyFrequency =>
        targetWeeklySessions == null || targetWeeklySessions! <= 0
            ? 0.0
            : weeklySessionsIncludingCurrent / targetWeeklySessions!,
    };
    return raw.clamp(0.0, 1.0);
  }

  bool isReached({
    required double distanceMeters,
    required int movingSeconds,
    int weeklySessionsIncludingCurrent = 0,
  }) {
    return switch (type) {
      RunningGoalType.distance =>
        distanceMeters >= (targetDistanceMeters ?? double.infinity),
      RunningGoalType.time =>
        movingSeconds >= (targetDurationSeconds ?? 1 << 30),
      RunningGoalType.weeklyFrequency =>
        weeklySessionsIncludingCurrent >= (targetWeeklySessions ?? 1 << 30),
    };
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'targetDistanceMeters': targetDistanceMeters,
    'targetDurationSeconds': targetDurationSeconds,
    'targetWeeklySessions': targetWeeklySessions,
  };

  factory RunningGoal.fromJson(Map<String, dynamic> json) {
    final type = RunningGoalType.values.firstWhere(
      (value) => value.name == json['type'],
      orElse: () => RunningGoalType.distance,
    );

    return switch (type) {
      RunningGoalType.distance => RunningGoal.distance(
        (json['targetDistanceMeters'] as num?)?.toDouble() ?? 0,
      ),
      RunningGoalType.time => RunningGoal.time(
        json['targetDurationSeconds'] as int? ?? 0,
      ),
      RunningGoalType.weeklyFrequency => RunningGoal.weeklyFrequency(
        json['targetWeeklySessions'] as int? ?? 0,
      ),
    };
  }
}
