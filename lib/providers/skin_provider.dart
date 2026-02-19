import 'package:flutter/foundation.dart';
import '../models/timer_skin.dart';
import '../services/storage_service.dart';

class SkinProvider extends ChangeNotifier {
  final StorageService _storage;
  TimerSkin _skin = TimerSkin.classic;

  SkinProvider(this._storage) {
    final saved = _storage.loadSkin();
    if (saved != null) {
      try {
        _skin = TimerSkin.values.byName(saved);
      } catch (_) {
        // Invalid saved value, keep default
      }
    }
  }

  TimerSkin get skin => _skin;

  set skin(TimerSkin value) {
    if (_skin == value) return;
    _skin = value;
    _storage.saveSkin(value.name);
    notifyListeners();
  }
}
