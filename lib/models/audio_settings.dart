class AudioSettings {
  final String? workMusic;
  final String? restMusic;
  final String startTone;
  final String endTone;

  const AudioSettings({
    this.workMusic,
    this.restMusic,
    this.startTone = 'default',
    this.endTone = 'default',
  });

  AudioSettings copyWith({
    String? Function()? workMusic,
    String? Function()? restMusic,
    String? startTone,
    String? endTone,
  }) {
    return AudioSettings(
      workMusic: workMusic != null ? workMusic() : this.workMusic,
      restMusic: restMusic != null ? restMusic() : this.restMusic,
      startTone: startTone ?? this.startTone,
      endTone: endTone ?? this.endTone,
    );
  }

  Map<String, dynamic> toJson() => {
        'workMusic': workMusic,
        'restMusic': restMusic,
        'startTone': startTone,
        'endTone': endTone,
      };

  factory AudioSettings.fromJson(Map<String, dynamic> json) => AudioSettings(
        workMusic: json['workMusic'] as String?,
        restMusic: json['restMusic'] as String?,
        startTone: json['startTone'] as String? ?? 'default',
        endTone: json['endTone'] as String? ?? 'default',
      );
}
