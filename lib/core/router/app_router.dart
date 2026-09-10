import 'package:go_router/go_router.dart';
import '../../models/timer_type.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/config/classic_config_screen.dart';
import '../../screens/config/tabata_config_screen.dart';
import '../../screens/config/custom_config_screen.dart';
import '../../screens/timer/active_timer_screen.dart';
import '../../screens/presets/presets_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/audio/audio_settings_screen.dart';
import '../../models/running_session.dart';
import '../../screens/running/running_active_screen.dart';
import '../../screens/running/running_dashboard_screen.dart';
import '../../screens/running/running_history_screen.dart';
import '../../screens/running/running_route_detail_screen.dart';
import '../../screens/running/running_settings_screen.dart';
import '../../screens/running/running_summary_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/classic/config',
        builder: (context, state) => const ClassicConfigScreen(),
      ),
      GoRoute(
        path: '/tabata/config',
        builder: (context, state) => const TabataConfigScreen(),
      ),
      GoRoute(
        path: '/custom/config',
        builder: (context, state) => const CustomConfigScreen(),
      ),
      GoRoute(
        path: '/timer',
        builder: (context, state) {
          final type = state.extra as TimerType;
          return ActiveTimerScreen(type: type);
        },
      ),
      GoRoute(
        path: '/presets',
        builder: (context, state) => const PresetsScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/audio-settings',
        builder: (context, state) => const AudioSettingsScreen(),
      ),
      GoRoute(
        path: '/running',
        builder: (context, state) => const RunningDashboardScreen(),
      ),
      GoRoute(
        path: '/running/active',
        builder: (context, state) => const RunningActiveScreen(),
      ),
      GoRoute(
        path: '/running/summary',
        builder: (context, state) =>
            RunningSummaryScreen(session: state.extra as RunningSession),
      ),
      GoRoute(
        path: '/running/history',
        builder: (context, state) => const RunningHistoryScreen(),
      ),
      GoRoute(
        path: '/running/settings',
        builder: (context, state) => const RunningSettingsScreen(),
      ),
      GoRoute(
        path: '/running/route',
        builder: (context, state) =>
            RunningRouteDetailScreen(session: state.extra as RunningSession),
      ),
    ],
  );
}
