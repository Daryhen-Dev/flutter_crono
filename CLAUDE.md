# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter chronometer/timer app (currently scaffolded as the default counter demo). Targets all platforms: Android, iOS, Web, Linux, macOS, Windows.

- **SDK constraints:** Dart >=3.9.2 <4.0.0, Flutter >=3.18.0
- **State management:** `setState()` (no external state management packages)
- **Linting:** `flutter_lints` (standard recommended rules, no overrides)

## Common Commands

```bash
# Run the app
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code (lint)
flutter analyze

# Get dependencies
flutter pub get

# Build for a specific platform
flutter build apk        # Android
flutter build ios         # iOS
flutter build web         # Web
flutter build windows     # Windows
```

## Architecture

All application code lives in `lib/main.dart` (single-file scaffold). As features are added, the codebase should be structured under `lib/` with appropriate separation.
