class RunningSettings {
  final double maxAccuracyMeters;
  final double maxHumanSpeedMps;
  final double autoPauseSpeedMps;
  final int autoPauseAfterSeconds;
  final double paceWindowMeters;

  const RunningSettings({
    this.maxAccuracyMeters = 25,
    this.maxHumanSpeedMps = 8.5,
    this.autoPauseSpeedMps = 0.7,
    this.autoPauseAfterSeconds = 8,
    this.paceWindowMeters = 200,
  });

  RunningSettings copyWith({
    double? maxAccuracyMeters,
    double? maxHumanSpeedMps,
    double? autoPauseSpeedMps,
    int? autoPauseAfterSeconds,
    double? paceWindowMeters,
  }) {
    return RunningSettings(
      maxAccuracyMeters: maxAccuracyMeters ?? this.maxAccuracyMeters,
      maxHumanSpeedMps: maxHumanSpeedMps ?? this.maxHumanSpeedMps,
      autoPauseSpeedMps: autoPauseSpeedMps ?? this.autoPauseSpeedMps,
      autoPauseAfterSeconds:
          autoPauseAfterSeconds ?? this.autoPauseAfterSeconds,
      paceWindowMeters: paceWindowMeters ?? this.paceWindowMeters,
    );
  }

  Map<String, dynamic> toJson() => {
    'maxAccuracyMeters': maxAccuracyMeters,
    'maxHumanSpeedMps': maxHumanSpeedMps,
    'autoPauseSpeedMps': autoPauseSpeedMps,
    'autoPauseAfterSeconds': autoPauseAfterSeconds,
    'paceWindowMeters': paceWindowMeters,
  };

  factory RunningSettings.fromJson(Map<String, dynamic> json) {
    return RunningSettings(
      maxAccuracyMeters: (json['maxAccuracyMeters'] as num?)?.toDouble() ?? 25,
      maxHumanSpeedMps: (json['maxHumanSpeedMps'] as num?)?.toDouble() ?? 8.5,
      autoPauseSpeedMps: (json['autoPauseSpeedMps'] as num?)?.toDouble() ?? 0.7,
      autoPauseAfterSeconds: json['autoPauseAfterSeconds'] as int? ?? 8,
      paceWindowMeters: (json['paceWindowMeters'] as num?)?.toDouble() ?? 200,
    );
  }
}
