import 'timer_type.dart';

class WorkoutRecord {
  final String id;
  final TimerType type;
  final DateTime startedAt;
  final DateTime completedAt;
  final int totalSeconds;
  final int roundsCompleted;
  final int tabatasCompleted;
  final String configJson;

  const WorkoutRecord({
    required this.id,
    required this.type,
    required this.startedAt,
    required this.completedAt,
    required this.totalSeconds,
    required this.roundsCompleted,
    required this.tabatasCompleted,
    required this.configJson,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt.toIso8601String(),
        'totalSeconds': totalSeconds,
        'roundsCompleted': roundsCompleted,
        'tabatasCompleted': tabatasCompleted,
        'configJson': configJson,
      };

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) => WorkoutRecord(
        id: json['id'] as String,
        type: TimerType.values.byName(json['type'] as String),
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: DateTime.parse(json['completedAt'] as String),
        totalSeconds: json['totalSeconds'] as int,
        roundsCompleted: json['roundsCompleted'] as int,
        tabatasCompleted: json['tabatasCompleted'] as int,
        configJson: json['configJson'] as String,
      );
}
