import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'services/storage_service.dart';
import 'providers/presets_provider.dart';
import 'providers/classic_config_provider.dart';
import 'providers/tabata_config_provider.dart';
import 'providers/custom_config_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/history_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);

  runApp(CronoApp(storage: storage));
}

class CronoApp extends StatelessWidget {
  final StorageService storage;

  const CronoApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PresetsProvider(storage)),
        ChangeNotifierProvider(create: (_) => ClassicConfigProvider()),
        ChangeNotifierProvider(create: (_) => TabataConfigProvider()),
        ChangeNotifierProvider(create: (_) => CustomConfigProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider(storage)),
      ],
      child: MaterialApp.router(
        title: 'Crono',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
