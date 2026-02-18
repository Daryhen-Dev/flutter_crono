import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/preset.dart';
import '../models/workout_record.dart';

class StorageService {
  static const _presetsKey = 'presets';
  static const _historyKey = 'history';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  List<Preset> loadPresets() {
    final raw = _prefs.getString(_presetsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Preset.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePresets(List<Preset> presets) async {
    final json = jsonEncode(presets.map((p) => p.toJson()).toList());
    await _prefs.setString(_presetsKey, json);
  }

  List<WorkoutRecord> loadHistory() {
    final raw = _prefs.getString(_historyKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => WorkoutRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHistory(List<WorkoutRecord> records) async {
    final json = jsonEncode(records.map((r) => r.toJson()).toList());
    await _prefs.setString(_historyKey, json);
  }
}
