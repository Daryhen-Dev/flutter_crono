import 'package:flutter/foundation.dart';
import '../models/audio_settings.dart';
import '../services/storage_service.dart';

class AudioSettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  AudioSettings _settings;

  AudioSettingsProvider(this._storage)
      : _settings = _storage.loadAudioSettings();

  AudioSettings get settings => _settings;

  void setWorkMusic(String? music) {
    _settings = _settings.copyWith(workMusic: () => music);
    _save();
  }

  void setRestMusic(String? music) {
    _settings = _settings.copyWith(restMusic: () => music);
    _save();
  }

  void setStartTone(String tone) {
    _settings = _settings.copyWith(startTone: tone);
    _save();
  }

  void setEndTone(String tone) {
    _settings = _settings.copyWith(endTone: tone);
    _save();
  }

  void _save() {
    _storage.saveAudioSettings(_settings);
    notifyListeners();
  }
}
