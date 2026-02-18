class TabataConfig {
  final int preparationSeconds;
  final int workSeconds;
  final int restSeconds;
  final int roundCount;
  final int tabataCount;
  final int tabataRestSeconds;

  const TabataConfig({
    this.preparationSeconds = 10,
    this.workSeconds = 20,
    this.restSeconds = 10,
    this.roundCount = 8,
    this.tabataCount = 1,
    this.tabataRestSeconds = 60,
  });

  Map<String, dynamic> toJson() => {
        'preparationSeconds': preparationSeconds,
        'workSeconds': workSeconds,
        'restSeconds': restSeconds,
        'roundCount': roundCount,
        'tabataCount': tabataCount,
        'tabataRestSeconds': tabataRestSeconds,
      };

  factory TabataConfig.fromJson(Map<String, dynamic> json) => TabataConfig(
        preparationSeconds: json['preparationSeconds'] as int,
        workSeconds: json['workSeconds'] as int,
        restSeconds: json['restSeconds'] as int,
        roundCount: json['roundCount'] as int,
        tabataCount: json['tabataCount'] as int,
        tabataRestSeconds: json['tabataRestSeconds'] as int,
      );

  TabataConfig copyWith({
    int? preparationSeconds,
    int? workSeconds,
    int? restSeconds,
    int? roundCount,
    int? tabataCount,
    int? tabataRestSeconds,
  }) =>
      TabataConfig(
        preparationSeconds: preparationSeconds ?? this.preparationSeconds,
        workSeconds: workSeconds ?? this.workSeconds,
        restSeconds: restSeconds ?? this.restSeconds,
        roundCount: roundCount ?? this.roundCount,
        tabataCount: tabataCount ?? this.tabataCount,
        tabataRestSeconds: tabataRestSeconds ?? this.tabataRestSeconds,
      );
}
