import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/preset.dart';
import '../models/timer_type.dart';
import '../services/storage_service.dart';

class PresetsProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Preset> _presets = [];

  PresetsProvider(this._storage) {
    _presets = _storage.loadPresets();
  }

  List<Preset> get presets => List.unmodifiable(_presets);

  Future<void> add({
    required String name,
    required TimerType type,
    required Map<String, dynamic> config,
  }) async {
    final preset = Preset(
      id: const Uuid().v4(),
      name: name,
      type: type,
      configJson: jsonEncode(config),
      createdAt: DateTime.now(),
    );
    _presets.insert(0, preset);
    await _storage.savePresets(_presets);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _presets.removeWhere((p) => p.id == id);
    await _storage.savePresets(_presets);
    notifyListeners();
  }
}
