class RunningPauseEvent {
  final DateTime startedAt;
  final DateTime endedAt;
  final bool automatic;

  const RunningPauseEvent({
    required this.startedAt,
    required this.endedAt,
    required this.automatic,
  });

  int get durationSeconds => endedAt.difference(startedAt).inSeconds;

  Map<String, dynamic> toJson() => {
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt.toIso8601String(),
    'automatic': automatic,
  };

  factory RunningPauseEvent.fromJson(Map<String, dynamic> json) {
    return RunningPauseEvent(
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      automatic: json['automatic'] as bool? ?? false,
    );
  }
}
