import 'package:flutter_crono/models/running_goal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RunningGoal.distance', () {
    const target = 5000.0; // 5 km
    const goal = RunningGoal.distance(target);

    test('progress is the ratio of distance to target, clamped to [0, 1]', () {
      expect(goal.progress(distanceMeters: 0, movingSeconds: 0), 0.0);
      expect(goal.progress(distanceMeters: 2500, movingSeconds: 0), 0.5);
      expect(goal.progress(distanceMeters: target, movingSeconds: 0), 1.0);
      // Overshooting the target stays clamped at 1.0.
      expect(goal.progress(distanceMeters: 10000, movingSeconds: 0), 1.0);
    });

    test('progress is 0 when the target is not positive', () {
      const zeroGoal = RunningGoal.distance(0);
      expect(zeroGoal.progress(distanceMeters: 1000, movingSeconds: 0), 0.0);
    });

    test('isReached only when distance meets or exceeds the target', () {
      expect(goal.isReached(distanceMeters: 4999, movingSeconds: 0), isFalse);
      expect(goal.isReached(distanceMeters: target, movingSeconds: 0), isTrue);
      expect(goal.isReached(distanceMeters: 6000, movingSeconds: 0), isTrue);
    });
  });

  group('RunningGoal.time', () {
    const target = 1800; // 30 minutes of moving time
    const goal = RunningGoal.time(target);

    test('progress uses movingSeconds and clamps to [0, 1]', () {
      expect(goal.progress(distanceMeters: 0, movingSeconds: 0), 0.0);
      expect(goal.progress(distanceMeters: 0, movingSeconds: 900), 0.5);
      expect(goal.progress(distanceMeters: 0, movingSeconds: target), 1.0);
      expect(goal.progress(distanceMeters: 0, movingSeconds: 3600), 1.0);
    });

    test('progress is 0 when the target is not positive', () {
      const zeroGoal = RunningGoal.time(0);
      expect(zeroGoal.progress(distanceMeters: 0, movingSeconds: 600), 0.0);
    });

    test('isReached only when movingSeconds meets or exceeds the target', () {
      expect(goal.isReached(distanceMeters: 0, movingSeconds: 1799), isFalse);
      expect(goal.isReached(distanceMeters: 0, movingSeconds: target), isTrue);
      expect(goal.isReached(distanceMeters: 0, movingSeconds: 2000), isTrue);
    });
  });

  group('RunningGoal.weeklyFrequency', () {
    const target = 3;
    const goal = RunningGoal.weeklyFrequency(target);

    test('progress uses weekly sessions and clamps to [0, 1]', () {
      expect(
        goal.progress(
          distanceMeters: 0,
          movingSeconds: 0,
          weeklySessionsIncludingCurrent: 0,
        ),
        0.0,
      );
      expect(
        goal.progress(
          distanceMeters: 0,
          movingSeconds: 0,
          weeklySessionsIncludingCurrent: 2,
        ),
        closeTo(2 / 3, 1e-9),
      );
      expect(
        goal.progress(
          distanceMeters: 0,
          movingSeconds: 0,
          weeklySessionsIncludingCurrent: 3,
        ),
        1.0,
      );
      expect(
        goal.progress(
          distanceMeters: 0,
          movingSeconds: 0,
          weeklySessionsIncludingCurrent: 5,
        ),
        1.0,
      );
    });

    test('isReached only when weekly sessions meet or exceed the target', () {
      expect(
        goal.isReached(
          distanceMeters: 0,
          movingSeconds: 0,
          weeklySessionsIncludingCurrent: 2,
        ),
        isFalse,
      );
      expect(
        goal.isReached(
          distanceMeters: 0,
          movingSeconds: 0,
          weeklySessionsIncludingCurrent: 3,
        ),
        isTrue,
      );
      expect(
        goal.isReached(
          distanceMeters: 0,
          movingSeconds: 0,
          weeklySessionsIncludingCurrent: 4,
        ),
        isTrue,
      );
    });
  });

  group('RunningGoal JSON serialization', () {
    test('distance goal survives a round-trip', () {
      const original = RunningGoal.distance(5000);
      final restored = RunningGoal.fromJson(original.toJson());

      expect(restored.type, RunningGoalType.distance);
      expect(restored.targetDistanceMeters, 5000);
      expect(restored.targetDurationSeconds, isNull);
      expect(restored.targetWeeklySessions, isNull);
    });

    test('time goal survives a round-trip', () {
      const original = RunningGoal.time(1800);
      final restored = RunningGoal.fromJson(original.toJson());

      expect(restored.type, RunningGoalType.time);
      expect(restored.targetDurationSeconds, 1800);
      expect(restored.targetDistanceMeters, isNull);
      expect(restored.targetWeeklySessions, isNull);
    });

    test('weekly frequency goal survives a round-trip', () {
      const original = RunningGoal.weeklyFrequency(4);
      final restored = RunningGoal.fromJson(original.toJson());

      expect(restored.type, RunningGoalType.weeklyFrequency);
      expect(restored.targetWeeklySessions, 4);
      expect(restored.targetDistanceMeters, isNull);
      expect(restored.targetDurationSeconds, isNull);
    });

    test('unknown type falls back to a distance goal', () {
      final restored = RunningGoal.fromJson({
        'type': 'unknown-type',
        'targetDistanceMeters': 1234,
      });

      expect(restored.type, RunningGoalType.distance);
      expect(restored.targetDistanceMeters, 1234);
    });
  });
}
