import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../models/running_goal.dart';
import '../models/running_pause_event.dart';
import '../models/running_session.dart';
import '../models/running_settings.dart';
import '../models/running_track_point.dart';
import '../services/running_gps_filter.dart';
import '../services/running_metrics.dart';
import '../services/running_tracking_service.dart';

enum RunningStatus {
  idle,
  acquiring,
  running,
  paused,
  finished,
  permissionDenied,
}

class RunningProvider extends ChangeNotifier {
  final RunningTrackingService _trackingService;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;
  RunningGpsFilter? _filter;

  RunningStatus _status = RunningStatus.idle;
  DateTime? _startedAt;
  DateTime? _pauseStartedAt;
  DateTime? _stoppedSince;
  bool _autoPaused = false;
  int _pausedSeconds = 0;
  double _distanceMeters = 0;
  List<RunningTrackPoint> _route = [];
  List<RunningPauseEvent> _pauses = [];
  RunningSettings _settings = const RunningSettings();
  RunningGoal? _goal;
  int _weeklySessionsBeforeStart = 0;
  RunningSession? _lastSession;

  RunningProvider({RunningTrackingService? trackingService})
    : _trackingService = trackingService ?? RunningTrackingService();

  RunningStatus get status => _status;
  bool get isActive =>
      _status == RunningStatus.running || _status == RunningStatus.paused;
  bool get isPaused => _status == RunningStatus.paused;
  bool get autoPaused => _autoPaused;
  List<RunningTrackPoint> get route => List.unmodifiable(_route);
  double get distanceMeters => _distanceMeters;
  RunningGoal? get goal => _goal;
  int get weeklySessionsIncludingCurrent =>
      _goal?.type == RunningGoalType.weeklyFrequency && _startedAt != null
      ? _weeklySessionsBeforeStart + 1
      : _weeklySessionsBeforeStart;
  RunningSession? get lastSession => _lastSession;

  int get elapsedSeconds {
    final startedAt = _startedAt;
    if (startedAt == null) return 0;
    return DateTime.now().difference(startedAt).inSeconds;
  }

  int get movingSeconds {
    var paused = _pausedSeconds;
    final pauseStartedAt = _pauseStartedAt;
    if (pauseStartedAt != null) {
      paused += DateTime.now().difference(pauseStartedAt).inSeconds;
    }
    return (elapsedSeconds - paused).clamp(0, elapsedSeconds);
  }

  double get averageSpeedMps =>
      movingSeconds > 0 ? _distanceMeters / movingSeconds : 0;
  int? get averagePaceSecondsPerKm =>
      RunningMetrics.paceSecondsPerKm(_distanceMeters, movingSeconds);
  int? get currentPaceSecondsPerKm =>
      RunningMetrics.windowPaceSecondsPerKm(_route, _settings.paceWindowMeters);

  double get goalProgress =>
      _goal?.progress(
        distanceMeters: _distanceMeters,
        movingSeconds: movingSeconds,
        weeklySessionsIncludingCurrent: weeklySessionsIncludingCurrent,
      ) ??
      0;

  Future<bool> start(
    RunningSettings settings, {
    RunningGoal? goal,
    int weeklySessionsBeforeStart = 0,
  }) async {
    _settings = settings;
    _goal = goal;
    _weeklySessionsBeforeStart = weeklySessionsBeforeStart;
    _status = RunningStatus.acquiring;
    notifyListeners();

    final permission = await _trackingService.ensurePermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _status = RunningStatus.permissionDenied;
      _goal = null;
      _weeklySessionsBeforeStart = 0;
      notifyListeners();
      return false;
    }

    _filter = RunningGpsFilter(settings);
    _startedAt = DateTime.now();
    _pauseStartedAt = null;
    _stoppedSince = null;
    _autoPaused = false;
    _pausedSeconds = 0;
    _distanceMeters = 0;
    _route = [];
    _pauses = [];
    _lastSession = null;
    _status = RunningStatus.running;

    _positionSubscription?.cancel();
    _positionSubscription = _trackingService.positionStream().listen(
      _onPosition,
    );
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => notifyListeners(),
    );
    notifyListeners();
    return true;
  }

  void pause({bool automatic = false}) {
    if (_status != RunningStatus.running) return;
    _status = RunningStatus.paused;
    _autoPaused = automatic;
    _pauseStartedAt = DateTime.now();
    notifyListeners();
  }

  void resume({bool automatic = false}) {
    if (_status != RunningStatus.paused) return;
    final pauseStartedAt = _pauseStartedAt;
    if (pauseStartedAt != null) {
      final now = DateTime.now();
      _pausedSeconds += now.difference(pauseStartedAt).inSeconds;
      _pauses.add(
        RunningPauseEvent(
          startedAt: pauseStartedAt,
          endedAt: now,
          automatic: _autoPaused || automatic,
        ),
      );
    }
    _pauseStartedAt = null;
    _stoppedSince = null;
    _autoPaused = false;
    _status = RunningStatus.running;
    notifyListeners();
  }

  Future<RunningSession?> finish() async {
    if (_startedAt == null || _status == RunningStatus.idle) return null;
    if (_status == RunningStatus.paused) resume(automatic: _autoPaused);

    final completedAt = DateTime.now();
    final session = RunningSession(
      id: const Uuid().v4(),
      startedAt: _startedAt!,
      completedAt: completedAt,
      elapsedSeconds: completedAt.difference(_startedAt!).inSeconds,
      movingSeconds: movingSeconds,
      distanceMeters: _distanceMeters,
      averageSpeedMps: averageSpeedMps,
      averagePaceSecondsPerKm: averagePaceSecondsPerKm,
      route: List.unmodifiable(_route),
      pauses: List.unmodifiable(_pauses),
      goal: _goal,
      goalReached: _goal?.type == RunningGoalType.weeklyFrequency
          ? false
          : _goal?.isReached(
              distanceMeters: _distanceMeters,
              movingSeconds: movingSeconds,
            ),
    );

    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _timer?.cancel();
    _timer = null;
    _lastSession = session;
    _status = RunningStatus.finished;
    notifyListeners();
    return session;
  }

  Future<void> reset() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _timer?.cancel();
    _timer = null;
    _status = RunningStatus.idle;
    _startedAt = null;
    _pauseStartedAt = null;
    _stoppedSince = null;
    _autoPaused = false;
    _pausedSeconds = 0;
    _distanceMeters = 0;
    _route = [];
    _pauses = [];
    _goal = null;
    _weeklySessionsBeforeStart = 0;
    notifyListeners();
  }

  void _onPosition(Position position) {
    final point = _filter?.accept(position);
    if (point == null) return;

    _handleAutoPause(point);
    if (_status == RunningStatus.running) {
      if (_route.isNotEmpty) {
        _distanceMeters += RunningMetrics.distance(_route.last, point);
      }
      _route.add(point);
    }
    notifyListeners();
  }

  void _handleAutoPause(RunningTrackPoint point) {
    if (_status == RunningStatus.paused && _autoPaused) {
      if (point.speed > _settings.autoPauseSpeedMps) resume(automatic: true);
      return;
    }
    if (_status != RunningStatus.running) return;

    if (point.speed <= _settings.autoPauseSpeedMps) {
      _stoppedSince ??= point.timestamp;
      final stoppedSeconds = point.timestamp
          .difference(_stoppedSince!)
          .inSeconds;
      if (stoppedSeconds >= _settings.autoPauseAfterSeconds) {
        pause(automatic: true);
      }
    } else {
      _stoppedSince = null;
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
