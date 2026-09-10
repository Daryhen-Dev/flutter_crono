import 'package:flutter_crono/models/running_goal.dart';
import 'package:flutter_crono/models/running_session.dart';
import 'package:flutter_crono/providers/running_history_provider.dart';
import 'package:flutter_crono/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

RunningSession buildSession({
  required DateTime completedAt,
  String? id,
  double distanceMeters = 1000,
  int movingSeconds = 600,
  RunningGoal? goal,
  bool? goalReached,
}) {
  return RunningSession(
    id: id ?? completedAt.toIso8601String(),
    startedAt: completedAt.subtract(Duration(seconds: movingSeconds)),
    completedAt: completedAt,
    elapsedSeconds: movingSeconds,
    movingSeconds: movingSeconds,
    distanceMeters: distanceMeters,
    averageSpeedMps: 2.5,
    averagePaceSecondsPerKm: 400,
    route: const [],
    pauses: const [],
    goal: goal,
    goalReached: goalReached,
  );
}

Future<StorageService> buildStorage([
  List<RunningSession> seed = const [],
]) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);
  if (seed.isNotEmpty) {
    await storage.saveRunningSessions(seed);
  }
  return storage;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('aggregate stats', () {
    test(
      'total distance and completed sessions reflect stored sessions',
      () async {
        final now = DateTime.now();
        final storage = await buildStorage([
          buildSession(completedAt: now, distanceMeters: 3000),
          buildSession(
            completedAt: now.subtract(const Duration(days: 2)),
            distanceMeters: 5000,
          ),
        ]);
        final provider = RunningHistoryProvider(storage);

        expect(provider.completedSessions, 2);
        expect(provider.totalDistanceMeters, 8000);
      },
    );

    test('empty history reports zeroed stats', () async {
      final provider = RunningHistoryProvider(await buildStorage());

      expect(provider.completedSessions, 0);
      expect(provider.totalDistanceMeters, 0);
      expect(provider.currentStreakDays, 0);
    });
  });

  group('currentStreakDays', () {
    test('counts consecutive days ending today', () async {
      final today = DateTime.now();
      final storage = await buildStorage([
        buildSession(completedAt: today, id: 'a'),
        buildSession(
          completedAt: today.subtract(const Duration(days: 1)),
          id: 'b',
        ),
        buildSession(
          completedAt: today.subtract(const Duration(days: 2)),
          id: 'c',
        ),
      ]);
      final provider = RunningHistoryProvider(storage);

      expect(provider.currentStreakDays, 3);
    });

    test('multiple sessions on the same day count as one streak day', () async {
      final today = DateTime.now();
      final storage = await buildStorage([
        buildSession(completedAt: today, id: 'a'),
        buildSession(completedAt: today.add(const Duration(hours: 1)), id: 'b'),
      ]);
      final provider = RunningHistoryProvider(storage);

      expect(provider.currentStreakDays, 1);
    });

    test('streak still counts when the most recent day is yesterday', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final storage = await buildStorage([
        buildSession(completedAt: yesterday, id: 'a'),
        buildSession(
          completedAt: yesterday.subtract(const Duration(days: 1)),
          id: 'b',
        ),
      ]);
      final provider = RunningHistoryProvider(storage);

      expect(provider.currentStreakDays, 2);
    });

    test('a gap of two or more days breaks the streak', () async {
      final today = DateTime.now();
      final storage = await buildStorage([
        buildSession(completedAt: today, id: 'a'),
        buildSession(
          completedAt: today.subtract(const Duration(days: 3)),
          id: 'b',
        ),
      ]);
      final provider = RunningHistoryProvider(storage);

      expect(provider.currentStreakDays, 1);
    });
  });

  group('sessionsInWeek', () {
    // 2024-01-01 is a Monday, so the week window is Jan 1 (incl.) to Jan 8 (excl.).
    final monday = DateTime(2024, 1, 1, 8);
    final wednesday = DateTime(2024, 1, 3, 8);
    final friday = DateTime(2024, 1, 5, 8);
    final nextMonday = DateTime(2024, 1, 8, 8);

    test('counts only sessions inside the Monday-Sunday window', () async {
      final storage = await buildStorage([
        buildSession(completedAt: monday, id: 'mon'),
        buildSession(completedAt: wednesday, id: 'wed'),
        buildSession(completedAt: friday, id: 'fri'),
        buildSession(completedAt: nextMonday, id: 'next-mon'),
      ]);
      final provider = RunningHistoryProvider(storage);

      expect(provider.sessionsInWeek(wednesday), 3);
      expect(provider.sessionsInWeek(nextMonday), 1);
    });
  });

  group('weekly frequency goal result on add', () {
    // 2024-01-01 is a Monday.
    final monday = DateTime(2024, 1, 1, 8);
    final wednesday = DateTime(2024, 1, 3, 8);
    final friday = DateTime(2024, 1, 5, 8);

    test(
      'marks the weekly goal reached once the target is met in the week',
      () async {
        final provider = RunningHistoryProvider(await buildStorage());

        await provider.add(buildSession(completedAt: monday, id: 'mon'));
        await provider.add(buildSession(completedAt: wednesday, id: 'wed'));
        final third = await provider.add(
          buildSession(
            completedAt: friday,
            id: 'fri',
            goal: const RunningGoal.weeklyFrequency(3),
          ),
        );

        expect(third.goalReached, isTrue);
      },
    );

    test(
      'leaves the weekly goal unreached when the target is not met',
      () async {
        final provider = RunningHistoryProvider(await buildStorage());

        await provider.add(buildSession(completedAt: monday, id: 'mon'));
        final second = await provider.add(
          buildSession(
            completedAt: wednesday,
            id: 'wed',
            goal: const RunningGoal.weeklyFrequency(3),
          ),
        );

        expect(second.goalReached, isFalse);
      },
    );
  });
}
