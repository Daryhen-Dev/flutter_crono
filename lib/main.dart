import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'models/timer_skin.dart';
import 'services/storage_service.dart';
import 'providers/presets_provider.dart';
import 'providers/classic_config_provider.dart';
import 'providers/tabata_config_provider.dart';
import 'providers/custom_config_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/history_provider.dart';
import 'providers/skin_provider.dart';
import 'providers/audio_settings_provider.dart';

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
        ChangeNotifierProvider(create: (_) => SkinProvider(storage)),
        ChangeNotifierProvider(create: (_) => AudioSettingsProvider(storage)),
      ],
      child: _ThemedApp(),
    );
  }
}

class _ThemedApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialApp.router must NOT rebuild when skin changes,
    // otherwise GoRouter's internal GlobalKey conflicts.
    // Theme + background are applied inside the builder instead.
    return MaterialApp.router(
      title: 'Tip Tap Workout',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: AppRouter.router,
      builder: (context, child) => _SkinShell(child: child!),
    );
  }
}

class _SkinShell extends StatelessWidget {
  final Widget child;

  const _SkinShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final skin = context.watch<SkinProvider>().skin;

    final theme = switch (skin) {
      TimerSkin.classic => AppTheme.dark,
      TimerSkin.cyberGrid => AppTheme.cyber,
      TimerSkin.terminal => AppTheme.terminal,
    };

    final bgColor = switch (skin) {
      TimerSkin.cyberGrid => CyberColors.background,
      TimerSkin.terminal => TerminalColors.background,
      _ => Colors.transparent,
    };

    return Theme(
      data: theme,
      child: ColoredBox(
        color: bgColor,
        child: Stack(
          children: [
            if (skin == TimerSkin.cyberGrid)
              Positioned.fill(
                child: CustomPaint(painter: _GridPainter()),
              ),
            if (skin == TimerSkin.terminal) const Positioned.fill(child: _MatrixRain()),
            child,
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CyberColors.cyan.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    const spacing = 40.0;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Matrix Rain Background ---

class _MatrixRain extends StatefulWidget {
  const _MatrixRain();

  @override
  State<_MatrixRain> createState() => _MatrixRainState();
}

class _MatrixRainState extends State<_MatrixRain>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_RainColumn> _columns = [];
  final _random = Random();
  Size _lastSize = Size.zero;

  // Katakana + numbers + a few latin chars
  static const _chars =
      'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン'
      '0123456789ABCDEFZ';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initColumns(Size size) {
    if (size == _lastSize) return;
    _lastSize = size;
    _columns.clear();

    const colWidth = 18.0;
    final count = (size.width / colWidth).ceil();

    for (int i = 0; i < count; i++) {
      _columns.add(_RainColumn(
        x: i * colWidth,
        speed: 1.0 + _random.nextDouble() * 2.5,
        y: -_random.nextDouble() * size.height * 2,
        length: 8 + _random.nextInt(18),
        chars: List.generate(
          8 + _random.nextInt(18),
          (_) => _chars[_random.nextInt(_chars.length)],
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _MatrixPainter(
              columns: _columns,
              random: _random,
              chars: _chars,
              onInit: _initColumns,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _RainColumn {
  double x;
  double speed;
  double y;
  int length;
  List<String> chars;

  _RainColumn({
    required this.x,
    required this.speed,
    required this.y,
    required this.length,
    required this.chars,
  });
}

class _MatrixPainter extends CustomPainter {
  final List<_RainColumn> columns;
  final Random random;
  final String chars;
  final void Function(Size) onInit;

  _MatrixPainter({
    required this.columns,
    required this.random,
    required this.chars,
    required this.onInit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    onInit(size);

    const fontSize = 14.0;
    const step = 18.0;

    for (final col in columns) {
      col.y += col.speed;

      // Reset when fully off screen
      if ((col.y - col.length * step) > size.height) {
        col.y = -random.nextDouble() * size.height * 0.5;
        col.speed = 1.0 + random.nextDouble() * 2.5;
        col.length = 8 + random.nextInt(18);
        col.chars = List.generate(
          col.length,
          (_) => chars[random.nextInt(chars.length)],
        );
      }

      // Randomly mutate one char per frame
      if (col.chars.isNotEmpty) {
        final idx = random.nextInt(col.chars.length);
        col.chars[idx] = chars[random.nextInt(chars.length)];
      }

      for (int j = 0; j < col.chars.length; j++) {
        final charY = col.y - j * step;
        if (charY < -step || charY > size.height + step) continue;

        // Head char is brightest, tail fades out
        final fade = 1.0 - (j / col.chars.length);
        final alpha = j == 0 ? 0.95 : (fade * 0.45).clamp(0.03, 0.45);

        final tp = TextPainter(
          text: TextSpan(
            text: col.chars[j],
            style: TextStyle(
              color: j == 0
                  ? const Color(0xFFCCFFCC).withValues(alpha: 0.9)
                  : TerminalColors.green.withValues(alpha: alpha),
              fontSize: fontSize,
              fontFamily: 'monospace',
              fontWeight: j == 0 ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(col.x, charY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
