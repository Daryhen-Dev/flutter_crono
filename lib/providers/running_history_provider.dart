import 'package:flutter/foundation.dart';
import '../models/running_goal.dart';
import '../models/running_session.dart';
import '../services/storage_service.dart';

class RunningHistoryProvider extends ChangeNotifier {
  final StorageService _storage;
  List<RunningSession> _sessions = [];

  RunningHistoryProvider(this._storage) {
    _sessions = _storage.loadRunningSessions();
  }

  List<RunningSession> get sessions => List.unmodifiable(_sessions);

  double get totalDistanceMeters =>
      _sessions.fold(0, (sum, session) => sum + session.distanceMeters);

  int get completedSessions => _sessions.length;

  int get currentStreakDays {
    final days = _sessionDays();
    if (days.isEmpty) return 0;

    var cursor = _dateOnly(DateTime.now());
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  RunningSession? get latestWeeklyGoalSession {
    for (final session in _sessions) {
      if (session.goal?.type == RunningGoalType.weeklyFrequency) {
        return session;
      }
    }
    return null;
  }

  Future<RunningSession> add(RunningSession session) async {
    final savedSession = _withFinalGoalResult(
      session,
      [
        _sessions,
        [session],
      ].expand((e) => e).toList(),
    );
    _sessions.insert(0, savedSession);
    await _storage.saveRunningSessions(_sessions);
    notifyListeners();
    return savedSession;
  }

  Future<void> remove(String id) async {
    _sessions.removeWhere((session) => session.id == id);
    await _storage.saveRunningSessions(_sessions);
    notifyListeners();
  }

  int sessionsInWeek(DateTime date) {
    final start = _startOfWeek(date);
    final end = start.add(const Duration(days: 7));
    return _sessions.where((session) {
      final completed = session.completedAt;
      return !completed.isBefore(start) && completed.isBefore(end);
    }).length;
  }

  Set<DateTime> sessionDaysInMonth(DateTime month) {
    return _sessions
        .where(
          (session) =>
              session.completedAt.year == month.year &&
              session.completedAt.month == month.month,
        )
        .map((session) => _dateOnly(session.completedAt))
        .toSet();
  }

  int weeklyGoalProgress(RunningSession weeklyGoalSession) {
    return sessionsInWeek(weeklyGoalSession.completedAt);
  }

  RunningSession _withFinalGoalResult(
    RunningSession session,
    List<RunningSession> sessionsIncludingCurrent,
  ) {
    final goal = session.goal;
    if (goal == null) return session;
    if (goal.type != RunningGoalType.weeklyFrequency) return session;

    final weeklySessions = sessionsIncludingCurrent.where((candidate) {
      final start = _startOfWeek(session.completedAt);
      final end = start.add(const Duration(days: 7));
      final completed = candidate.completedAt;
      return !completed.isBefore(start) && completed.isBefore(end);
    }).length;

    return session.copyWith(
      goalReached: goal.isReached(
        distanceMeters: session.distanceMeters,
        movingSeconds: session.movingSeconds,
        weeklySessionsIncludingCurrent: weeklySessions,
      ),
    );
  }

  Set<DateTime> _sessionDays() =>
      _sessions.map((session) => _dateOnly(session.completedAt)).toSet();

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _startOfWeek(DateTime date) {
    final day = _dateOnly(date);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }
}
