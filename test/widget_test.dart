import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_crono/models/timer_state.dart';
import 'package:flutter_crono/models/timer_phase.dart';
import 'package:flutter_crono/models/classic_config.dart';
import 'package:flutter_crono/models/tabata_config.dart';

void main() {
  test('TimerState formattedTime shows MM:SS', () {
    const state = TimerState(secondsRemaining: 125);
    expect(state.formattedTime, '02:05');
  });

  test('TimerState progress is correct', () {
    const state = TimerState(secondsRemaining: 5, totalPhaseSeconds: 10);
    expect(state.progress, 0.5);
  });

  test('ClassicConfig serialization round-trip', () {
    const config = ClassicConfig(
      preparationSeconds: 5,
      roundSeconds: 120,
      restSeconds: 30,
      roundCount: 4,
    );
    final json = config.toJson();
    final restored = ClassicConfig.fromJson(json);
    expect(restored.preparationSeconds, 5);
    expect(restored.roundCount, 4);
  });

  test('TabataConfig serialization round-trip', () {
    const config = TabataConfig(
      preparationSeconds: 10,
      workSeconds: 20,
      restSeconds: 10,
      roundCount: 8,
      tabataCount: 2,
      tabataRestSeconds: 60,
    );
    final json = config.toJson();
    final restored = TabataConfig.fromJson(json);
    expect(restored.tabataCount, 2);
    expect(restored.workSeconds, 20);
  });

  test('TimerPhase has correct display names', () {
    expect(TimerPhase.work.displayName, 'Trabajo');
    expect(TimerPhase.rest.displayName, 'Descanso');
    expect(TimerPhase.preparation.displayName, 'Preparación');
  });
}
