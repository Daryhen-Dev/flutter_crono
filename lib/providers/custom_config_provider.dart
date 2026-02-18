import 'package:flutter/foundation.dart';
import '../models/custom_config.dart';

class CustomConfigProvider extends ChangeNotifier {
  List<CustomSegment> _segments = [];
  int _restBetweenSeconds = 60;
  int _preparationSeconds = 10;

  CustomConfig get config => CustomConfig(
        segments: List.unmodifiable(_segments),
        restBetweenSeconds: _restBetweenSeconds,
        preparationSeconds: _preparationSeconds,
      );

  List<CustomSegment> get segments => List.unmodifiable(_segments);
  int get restBetweenSeconds => _restBetweenSeconds;
  int get preparationSeconds => _preparationSeconds;

  void addSegment(CustomSegment segment) {
    _segments.add(segment);
    notifyListeners();
  }

  void removeSegment(int index) {
    _segments.removeAt(index);
    notifyListeners();
  }

  void updateSegment(int index, CustomSegment segment) {
    _segments[index] = segment;
    notifyListeners();
  }

  void reorderSegments(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _segments.removeAt(oldIndex);
    _segments.insert(newIndex, item);
    notifyListeners();
  }

  void setRestBetween(int seconds) {
    _restBetweenSeconds = seconds.clamp(1, 5999);
    notifyListeners();
  }

  void setPreparation(int seconds) {
    _preparationSeconds = seconds.clamp(1, 5999);
    notifyListeners();
  }

  void loadConfig(CustomConfig config) {
    _segments = List.from(config.segments);
    _restBetweenSeconds = config.restBetweenSeconds;
    _preparationSeconds = config.preparationSeconds;
    notifyListeners();
  }
}
