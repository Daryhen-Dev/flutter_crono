import 'timer_phase.dart';

class TimerState {
  final TimerPhase phase;
  final int currentRound;
  final int totalRounds;
  final int currentTabata;
  final int totalTabatas;
  final int currentSegment;
  final int totalSegments;
  final int secondsRemaining;
  final int totalPhaseSeconds;
  final bool isRunning;
  final bool isPaused;

  const TimerState({
    this.phase = TimerPhase.idle,
    this.currentRound = 0,
    this.totalRounds = 0,
    this.currentTabata = 0,
    this.totalTabatas = 0,
    this.currentSegment = 0,
    this.totalSegments = 0,
    this.secondsRemaining = 0,
    this.totalPhaseSeconds = 0,
    this.isRunning = false,
    this.isPaused = false,
  });

  double get progress {
    if (totalPhaseSeconds == 0) return 0;
    return 1 - (secondsRemaining / totalPhaseSeconds);
  }

  String get formattedTime {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  TimerState copyWith({
    TimerPhase? phase,
    int? currentRound,
    int? totalRounds,
    int? currentTabata,
    int? totalTabatas,
    int? currentSegment,
    int? totalSegments,
    int? secondsRemaining,
    int? totalPhaseSeconds,
    bool? isRunning,
    bool? isPaused,
  }) =>
      TimerState(
        phase: phase ?? this.phase,
        currentRound: currentRound ?? this.currentRound,
        totalRounds: totalRounds ?? this.totalRounds,
        currentTabata: currentTabata ?? this.currentTabata,
        totalTabatas: totalTabatas ?? this.totalTabatas,
        currentSegment: currentSegment ?? this.currentSegment,
        totalSegments: totalSegments ?? this.totalSegments,
        secondsRemaining: secondsRemaining ?? this.secondsRemaining,
        totalPhaseSeconds: totalPhaseSeconds ?? this.totalPhaseSeconds,
        isRunning: isRunning ?? this.isRunning,
        isPaused: isPaused ?? this.isPaused,
      );
}
