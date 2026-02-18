import 'timer_type.dart';

class CustomSegment {
  final TimerType type; // classic or tabata (never personalizado)
  final int workSeconds;
  final int restSeconds;
  final int roundCount;

  const CustomSegment({
    this.type = TimerType.classic,
    this.workSeconds = 30,
    this.restSeconds = 15,
    this.roundCount = 4,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'workSeconds': workSeconds,
        'restSeconds': restSeconds,
        'roundCount': roundCount,
      };

  factory CustomSegment.fromJson(Map<String, dynamic> json) => CustomSegment(
        type: TimerType.values.byName(json['type'] as String),
        workSeconds: json['workSeconds'] as int,
        restSeconds: json['restSeconds'] as int,
        roundCount: json['roundCount'] as int,
      );

  CustomSegment copyWith({
    TimerType? type,
    int? workSeconds,
    int? restSeconds,
    int? roundCount,
  }) =>
      CustomSegment(
        type: type ?? this.type,
        workSeconds: workSeconds ?? this.workSeconds,
        restSeconds: restSeconds ?? this.restSeconds,
        roundCount: roundCount ?? this.roundCount,
      );
}

class CustomConfig {
  final List<CustomSegment> segments;
  final int restBetweenSeconds;
  final int preparationSeconds;

  const CustomConfig({
    this.segments = const [],
    this.restBetweenSeconds = 60,
    this.preparationSeconds = 10,
  });

  Map<String, dynamic> toJson() => {
        'segments': segments.map((s) => s.toJson()).toList(),
        'restBetweenSeconds': restBetweenSeconds,
        'preparationSeconds': preparationSeconds,
      };

  factory CustomConfig.fromJson(Map<String, dynamic> json) => CustomConfig(
        segments: (json['segments'] as List)
            .map((s) => CustomSegment.fromJson(s as Map<String, dynamic>))
            .toList(),
        restBetweenSeconds: json['restBetweenSeconds'] as int,
        preparationSeconds: json['preparationSeconds'] as int,
      );

  CustomConfig copyWith({
    List<CustomSegment>? segments,
    int? restBetweenSeconds,
    int? preparationSeconds,
  }) =>
      CustomConfig(
        segments: segments ?? this.segments,
        restBetweenSeconds: restBetweenSeconds ?? this.restBetweenSeconds,
        preparationSeconds: preparationSeconds ?? this.preparationSeconds,
      );
}
