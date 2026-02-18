class ClassicConfig {
  final int preparationSeconds;
  final int roundSeconds;
  final int restSeconds;
  final int roundCount;

  const ClassicConfig({
    this.preparationSeconds = 10,
    this.roundSeconds = 180,
    this.restSeconds = 60,
    this.roundCount = 3,
  });

  Map<String, dynamic> toJson() => {
        'preparationSeconds': preparationSeconds,
        'roundSeconds': roundSeconds,
        'restSeconds': restSeconds,
        'roundCount': roundCount,
      };

  factory ClassicConfig.fromJson(Map<String, dynamic> json) => ClassicConfig(
        preparationSeconds: json['preparationSeconds'] as int,
        roundSeconds: json['roundSeconds'] as int,
        restSeconds: json['restSeconds'] as int,
        roundCount: json['roundCount'] as int,
      );

  ClassicConfig copyWith({
    int? preparationSeconds,
    int? roundSeconds,
    int? restSeconds,
    int? roundCount,
  }) =>
      ClassicConfig(
        preparationSeconds: preparationSeconds ?? this.preparationSeconds,
        roundSeconds: roundSeconds ?? this.roundSeconds,
        restSeconds: restSeconds ?? this.restSeconds,
        roundCount: roundCount ?? this.roundCount,
      );
}
