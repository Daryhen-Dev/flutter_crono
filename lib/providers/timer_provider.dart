import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/timer_type.dart';
import '../models/timer_phase.dart';
import '../models/timer_state.dart';
import '../models/classic_config.dart';
import '../models/tabata_config.dart';
import '../models/custom_config.dart';
import '../models/workout_record.dart';
import '../services/audio_service.dart';

class TimerProvider extends ChangeNotifier {
  Timer? _ticker;
  TimerType? _type;
  TimerState _state = const TimerState();

  // Config references
  ClassicConfig? _classicConfig;
  TabataConfig? _tabataConfig;
  CustomConfig? _customConfig;

  // Custom sequence tracking
  int _currentSegmentIndex = 0;

  // Workout tracking
  DateTime? _startedAt;
  WorkoutRecord? _lastCompletedRecord;

  TimerState get state => _state;
  WorkoutRecord? get lastCompletedRecord => _lastCompletedRecord;

  void startClassic(ClassicConfig config) {
    _type = TimerType.classic;
    _classicConfig = config;
    _startedAt = DateTime.now();
    _lastCompletedRecord = null;
    _state = TimerState(
      phase: TimerPhase.preparation,
      currentRound: 1,
      totalRounds: config.roundCount,
      currentTabata: 0,
      totalTabatas: 0,
      secondsRemaining: config.preparationSeconds,
      totalPhaseSeconds: config.preparationSeconds,
      isRunning: true,
    );
    notifyListeners();
    _startTicker();
  }

  void startTabata(TabataConfig config) {
    _type = TimerType.tabata;
    _tabataConfig = config;
    _startedAt = DateTime.now();
    _lastCompletedRecord = null;
    _state = TimerState(
      phase: TimerPhase.preparation,
      currentRound: 1,
      totalRounds: config.roundCount,
      currentTabata: 1,
      totalTabatas: config.tabataCount,
      secondsRemaining: config.preparationSeconds,
      totalPhaseSeconds: config.preparationSeconds,
      isRunning: true,
    );
    notifyListeners();
    _startTicker();
  }

  void startCustom(CustomConfig config) {
    if (config.segments.isEmpty) return;

    _type = TimerType.personalizado;
    _customConfig = config;
    _currentSegmentIndex = 0;
    _startedAt = DateTime.now();
    _lastCompletedRecord = null;

    final firstSegment = config.segments[0];
    _state = TimerState(
      phase: TimerPhase.preparation,
      currentRound: 1,
      totalRounds: firstSegment.roundCount,
      currentSegment: 1,
      totalSegments: config.segments.length,
      secondsRemaining: config.preparationSeconds,
      totalPhaseSeconds: config.preparationSeconds,
      isRunning: true,
    );
    notifyListeners();
    _startTicker();
  }

  void pause() {
    _ticker?.cancel();
    _state = _state.copyWith(isRunning: false, isPaused: true);
    notifyListeners();
  }

  void resume() {
    _state = _state.copyWith(isRunning: true, isPaused: false);
    notifyListeners();
    _startTicker();
  }

  void stop() {
    _ticker?.cancel();
    _state = const TimerState();
    _type = null;
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final audio = AudioService.instance;

    if (_state.secondsRemaining > 1) {
      // Countdown beeps: 3 short at 4,3,2 — 1 long at 1
      final remaining = _state.secondsRemaining - 1; // value after decrement
      if (remaining >= 1 && remaining <= 3) {
        audio.playShortBeep();
      }
      _state = _state.copyWith(secondsRemaining: remaining);
      notifyListeners();
      return;
    }

    // Phase ending (secondsRemaining == 1) → long beep
    audio.playLongBeep();

    // Phase ended
    if (_type == TimerType.classic) {
      _advanceClassic();
    } else if (_type == TimerType.personalizado) {
      _advanceCustom();
    } else {
      _advanceTabata();
    }
    notifyListeners();
  }

  void _advanceClassic() {
    final config = _classicConfig!;
    switch (_state.phase) {
      case TimerPhase.preparation:
        _enterPhase(TimerPhase.work, config.roundSeconds);
      case TimerPhase.work:
        if (_state.currentRound < config.roundCount) {
          _enterPhase(TimerPhase.rest, config.restSeconds);
        } else {
          _finish();
        }
      case TimerPhase.rest:
        _state = _state.copyWith(currentRound: _state.currentRound + 1);
        _enterPhase(TimerPhase.work, config.roundSeconds);
      default:
        break;
    }
  }

  void _advanceTabata() {
    final config = _tabataConfig!;
    switch (_state.phase) {
      case TimerPhase.preparation:
        _enterPhase(TimerPhase.work, config.workSeconds);
      case TimerPhase.work:
        if (_state.currentRound < config.roundCount) {
          _enterPhase(TimerPhase.rest, config.restSeconds);
        } else if (_state.currentTabata < config.tabataCount) {
          _enterPhase(TimerPhase.tabataRest, config.tabataRestSeconds);
        } else {
          _finish();
        }
      case TimerPhase.rest:
        _state = _state.copyWith(currentRound: _state.currentRound + 1);
        _enterPhase(TimerPhase.work, config.workSeconds);
      case TimerPhase.tabataRest:
        _state = _state.copyWith(
          currentTabata: _state.currentTabata + 1,
          currentRound: 1,
        );
        _enterPhase(TimerPhase.work, config.workSeconds);
      default:
        break;
    }
  }

  void _advanceCustom() {
    final config = _customConfig!;
    final segment = config.segments[_currentSegmentIndex];

    switch (_state.phase) {
      case TimerPhase.preparation:
        _enterPhase(TimerPhase.work, segment.workSeconds);
      case TimerPhase.work:
        if (_state.currentRound < segment.roundCount) {
          // More rounds in this segment → rest then next round
          _enterPhase(TimerPhase.rest, segment.restSeconds);
        } else {
          // Segment finished → move to next segment or finish
          _advanceToNextSegment();
        }
      case TimerPhase.rest:
        _state = _state.copyWith(currentRound: _state.currentRound + 1);
        _enterPhase(TimerPhase.work, segment.workSeconds);
      case TimerPhase.segmentRest:
        // Rest between segments ended → start next segment
        _currentSegmentIndex++;
        final nextSegment = config.segments[_currentSegmentIndex];
        _state = _state.copyWith(
          currentRound: 1,
          totalRounds: nextSegment.roundCount,
          currentSegment: _currentSegmentIndex + 1,
        );
        _enterPhase(TimerPhase.work, nextSegment.workSeconds);
      default:
        break;
    }
  }

  void _advanceToNextSegment() {
    final config = _customConfig!;
    if (_currentSegmentIndex < config.segments.length - 1) {
      // More segments → segment rest
      _enterPhase(TimerPhase.segmentRest, config.restBetweenSeconds);
    } else {
      // Last segment → done
      _finish();
    }
  }

  void _enterPhase(TimerPhase phase, int seconds) {
    _state = _state.copyWith(
      phase: phase,
      secondsRemaining: seconds,
      totalPhaseSeconds: seconds,
    );
  }

  void _finish() {
    _ticker?.cancel();
    final now = DateTime.now();
    final totalSeconds = _startedAt != null
        ? now.difference(_startedAt!).inSeconds
        : 0;

    String configJson;
    if (_type == TimerType.classic) {
      configJson = jsonEncode(_classicConfig!.toJson());
    } else if (_type == TimerType.personalizado) {
      configJson = jsonEncode(_customConfig!.toJson());
    } else {
      configJson = jsonEncode(_tabataConfig!.toJson());
    }

    final int roundsCompleted;
    final int tabatasCompleted;
    if (_type == TimerType.personalizado) {
      roundsCompleted = _customConfig!.segments.fold(0, (sum, s) => sum + s.roundCount);
      tabatasCompleted = _customConfig!.segments.length;
    } else {
      roundsCompleted = _state.totalRounds;
      tabatasCompleted = _type == TimerType.tabata ? _state.totalTabatas : 0;
    }

    _lastCompletedRecord = WorkoutRecord(
      id: const Uuid().v4(),
      type: _type!,
      startedAt: _startedAt ?? now,
      completedAt: now,
      totalSeconds: totalSeconds,
      roundsCompleted: roundsCompleted,
      tabatasCompleted: tabatasCompleted,
      configJson: configJson,
    );

    _state = _state.copyWith(
      phase: TimerPhase.finished,
      secondsRemaining: 0,
      totalPhaseSeconds: 0,
      isRunning: false,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
