import '../../models/running_goal.dart';

class RunningFormatters {
  RunningFormatters._();

  static String duration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  static String distance(double meters) =>
      '${(meters / 1000).toStringAsFixed(2)} km';

  static String pace(int? secondsPerKm) {
    if (secondsPerKm == null || secondsPerKm <= 0) return '--:-- /km';
    final minutes = secondsPerKm ~/ 60;
    final seconds = secondsPerKm % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
  }

  static String speed(double metersPerSecond) {
    return '${(metersPerSecond * 3.6).toStringAsFixed(1)} km/h';
  }

  static String date(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String goal(RunningGoal goal) {
    return switch (goal.type) {
      RunningGoalType.distance =>
        'Meta: ${distance(goal.targetDistanceMeters ?? 0)}',
      RunningGoalType.time =>
        'Meta: ${duration(goal.targetDurationSeconds ?? 0)} en movimiento',
      RunningGoalType.weeklyFrequency =>
        'Meta: ${goal.targetWeeklySessions ?? 0} sesiones esta semana',
    };
  }

  static String goalResult(bool? reached) {
    return switch (reached) {
      true => 'Meta alcanzada',
      false => 'Meta no alcanzada',
      null => 'Sin meta',
    };
  }
}
