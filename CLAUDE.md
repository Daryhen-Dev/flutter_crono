# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Tip Tap Workout** — Flutter interval timer app for workouts. Spanish UI language.

- **Timer modes:** Clásico (rounds), Tabata (HIIT intervals), Personalizado (sequence builder mixing Clásico/Tabata blocks)
- **Visual skins:** Classic (dark/lime), Cyber Grid (cyan neon grid), Terminal (Matrix rain)
- **SDK:** Dart >=3.9.2
- **State management:** Provider (`ChangeNotifierProvider`)
- **Routing:** GoRouter (routes pass `TimerType` via `state.extra`)
- **Persistence:** SharedPreferences via `StorageService`
- **Audio:** `audioplayers` package — WAV beeps generated in memory, MP3 music from assets
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

- `main.dart` — Entry point, all providers registered via `MultiProvider`, `MaterialApp.router` with skin shell
- `core/router/app_router.dart` — GoRouter route definitions
- `core/theme/` — `AppColors` (phase colors), `AppTheme.dark/cyber/terminal`
- `models/` — Immutable data classes: configs, `TimerState`, `TimerPhase`, `TimerSkin`, `AudioSettings`, `Preset`, `WorkoutRecord`
- `providers/` — ChangeNotifiers: `TimerProvider` (tick logic), config providers (classic/tabata/custom), `SkinProvider`, `AudioSettingsProvider`, `PresetsProvider`, `HistoryProvider`
- `screens/config/` — Config screens per timer type + shared `DurationField`/`CounterField` widgets
- `screens/timer/` — `ActiveTimerScreen` routes to skin widgets; `skins/` has self-contained skin widgets
- `screens/audio/` — `AudioSettingsScreen` for music selection per phase
- `services/audio_service.dart` — Singleton: beep generation, music playback, ducking, preview
- `services/storage_service.dart` — SharedPreferences wrapper

### Skin System

`_SkinShell` in `main.dart` wraps the app in `Theme(data: ...)` + background painters. `MaterialApp.router` is built once with a static theme — skin switching happens inside the builder to avoid GoRouter `GlobalKey` conflicts.

Each timer skin (`screens/timer/skins/`) receives `TimerState` + callbacks (`onPause`, `onResume`, `onStop`).

### Audio System

`AudioService` is a singleton with three `AudioPlayer` instances:
- `_player` — beeps (WAV generated in memory, 880Hz sine wave)
- `_musicPlayer` — background music (MP3 assets, looped)
- `_previewPlayer` — short previews in settings screen

**Concurrent playback:** Beeps play over music using `AndroidAudioFocus.none` (Android) and `mixWithOthers` (iOS). Audio context is set lazily via `_ensurePlayerContext()` — must NOT be set in the constructor or it breaks playback.

**Ducking:** When a beep plays, music volume drops to `_duckedVolume` then restores to `_musicVolume`.

**Asset folders:** `assets/audio/work/` (work phase music), `assets/audio/rest/` (rest phase music), `assets/audio/tones/` (pending).

Music file lists are hardcoded in `AudioSettingsScreen` — update `_workFiles`/`_restFiles` when adding new MP3s.

### Timer Flow

1. Config screen sets values in config provider → navigates to `/timer` with `TimerType` as `extra`
2. `ActiveTimerScreen.initState()` reads config + audio settings providers, calls `TimerProvider.startClassic/Tabata/Custom()`
3. `TimerProvider._tick()` counts down, plays beeps at 4/3/2s (short) and 1s (long) before phase transitions
4. On phase transition (`_enterPhase`), music switches between work/rest tracks
5. On finish, `WorkoutRecord` is created and saved to history

### Nullable copyWith Pattern

`AudioSettings.copyWith` uses `String? Function()?` wrapper for nullable fields to distinguish "not provided" from "set to null":
```dart
copyWith({ String? Function()? workMusic }) =>
  AudioSettings(workMusic: workMusic != null ? workMusic() : this.workMusic)
```
