import 'package:flutter/material.dart';

enum TimerSkin {
  classic,
  cyberGrid,
  terminal;

  String get displayName {
    switch (this) {
      case TimerSkin.classic:
        return 'Clásico';
      case TimerSkin.cyberGrid:
        return 'Cuadrícula Cyber';
      case TimerSkin.terminal:
        return 'Terminal';
    }
  }

  IconData get icon {
    switch (this) {
      case TimerSkin.classic:
        return Icons.radio_button_unchecked;
      case TimerSkin.cyberGrid:
        return Icons.grid_4x4;
      case TimerSkin.terminal:
        return Icons.terminal;
    }
  }
}
