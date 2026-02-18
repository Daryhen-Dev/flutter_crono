enum TimerType {
  tabata,
  classic,
  personalizado;

  String get displayName {
    switch (this) {
      case TimerType.tabata:
        return 'Tabata';
      case TimerType.classic:
        return 'Clásico';
      case TimerType.personalizado:
        return 'Personalizado';
    }
  }
}
