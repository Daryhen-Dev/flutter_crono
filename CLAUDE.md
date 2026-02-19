# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter interval timer app for workouts (Clásico, Tabata, Personalizado modes). Supports visual skins (Classic dark, Cyber Grid, Terminal/Matrix). Spanish UI language.

- **SDK constraints:** Dart >=3.9.2, Flutter >=3.18.0
- **State management:** Provider (`ChangeNotifierProvider`)
- **Routing:** GoRouter
- **Persistence:** SharedPreferences via `StorageService`
- **Linting:** `flutter_lints`

## Common Commands

```bash
flutter run                           # Run the app
flutter analyze                       # Lint/analyze
flutter test                          # Run all tests
flutter test test/widget_test.dart    # Single test
flutter pub get                       # Get dependencies
```

## Architecture

```
lib/
├── main.dart                    # App entry, providers, MaterialApp.router, skin shell
├── core/
│   ├── router/app_router.dart   # GoRouter route definitions
│   └── theme/
│       ├── app_colors.dart      # Phase colors (work, rest, preparation)
│       └── app_theme.dart       # AppTheme.dark/cyber/terminal, CyberColors, TerminalColors
├── models/                      # Data classes: configs, TimerState, TimerPhase, TimerSkin, etc.
├── providers/                   # ChangeNotifiers: timer, config (classic/tabata/custom), skin, presets, history
├── screens/
│   ├── config/                  # Config screens per timer type + shared widgets (DurationField, CounterField)
│   ├── timer/
│   │   ├── active_timer_screen.dart  # Routes to skin widgets based on SkinProvider
│   │   ├── skins/               # ClassicSkin, CyberGridSkin, TerminalSkin
│   │   └── widgets/             # TimerRing, PhaseLabel, RoundIndicator, ControlButtons
│   ├── home/                    # Home screen with skin selector
│   ├── history/                 # Workout history with filters
│   └── presets/                 # Saved routine presets
└── services/
    ├── audio_service.dart       # Beep/sound feedback
    └── storage_service.dart     # SharedPreferences wrapper
```

### Skin System

Skins are applied globally via `_SkinShell` in `main.dart` which wraps the app in a `Theme` widget + background (grid painter for Cyber, Matrix rain for Terminal). `MaterialApp.router` is built once with a static theme to avoid GlobalKey conflicts — skin switching happens via `Theme(data: ...)` inside the builder.

Each timer skin (`lib/screens/timer/skins/`) is a self-contained widget receiving `TimerState` + callbacks (`onPause`, `onResume`, `onStop`).

### Config Screens

- **ClassicConfigScreen**: Expandable cards with centered scroll pickers (ListWheelScrollView)
- **TabataConfigScreen / CustomConfigScreen**: Use shared `DurationField` and `CounterField` widgets
