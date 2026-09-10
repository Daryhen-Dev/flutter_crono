import 'package:flutter/foundation.dart';
import '../models/running_settings.dart';
import '../services/storage_service.dart';

class RunningSettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  late RunningSettings _settings;

  RunningSettingsProvider(this._storage) {
    _settings = _storage.loadRunningSettings();
  }

  RunningSettings get settings => _settings;

  Future<void> update(RunningSettings settings) async {
    _settings = settings;
    await _storage.saveRunningSettings(settings);
    notifyListeners();
  }
}
