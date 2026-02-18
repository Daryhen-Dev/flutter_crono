import 'package:flutter/foundation.dart';
import '../models/workout_record.dart';
import '../models/timer_type.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  final StorageService _storage;
  List<WorkoutRecord> _records = [];

  HistoryProvider(this._storage) {
    _records = _storage.loadHistory();
  }

  List<WorkoutRecord> get records => List.unmodifiable(_records);

  Future<void> add(WorkoutRecord record) async {
    _records.insert(0, record);
    await _storage.saveHistory(_records);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _records.removeWhere((r) => r.id == id);
    await _storage.saveHistory(_records);
    notifyListeners();
  }

  List<WorkoutRecord> getByPeriod(DateTime start, DateTime end) {
    return _records.where((r) =>
        !r.completedAt.isBefore(start) && r.completedAt.isBefore(end)).toList();
  }

  List<WorkoutRecord> getWeek(DateTime referenceDate) {
    // Monday of the week
    final monday = referenceDate.subtract(
        Duration(days: referenceDate.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day);
    final end = start.add(const Duration(days: 7));
    return getByPeriod(start, end);
  }

  List<WorkoutRecord> getMonth(int year, int month) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    return getByPeriod(start, end);
  }

  List<WorkoutRecord> getYear(int year) {
    final start = DateTime(year);
    final end = DateTime(year + 1);
    return getByPeriod(start, end);
  }

  Map<String, dynamic> getSummary(List<WorkoutRecord> filtered) {
    final totalSessions = filtered.length;
    final totalSeconds =
        filtered.fold<int>(0, (sum, r) => sum + r.totalSeconds);
    final avgSeconds = totalSessions > 0 ? totalSeconds ~/ totalSessions : 0;
    return {
      'totalSessions': totalSessions,
      'totalSeconds': totalSeconds,
      'avgSeconds': avgSeconds,
    };
  }

  static List<WorkoutRecord> filterByType(
      List<WorkoutRecord> records, TimerType? type) {
    if (type == null) return records;
    return records.where((r) => r.type == type).toList();
  }
}
