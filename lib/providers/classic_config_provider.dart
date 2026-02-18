import 'package:flutter/foundation.dart';
import '../models/classic_config.dart';

class ClassicConfigProvider extends ChangeNotifier {
  ClassicConfig _config = const ClassicConfig();

  ClassicConfig get config => _config;

  void setPreparation(int seconds) {
    _config = _config.copyWith(preparationSeconds: seconds);
    notifyListeners();
  }

  void setRoundSeconds(int seconds) {
    _config = _config.copyWith(roundSeconds: seconds);
    notifyListeners();
  }

  void setRestSeconds(int seconds) {
    _config = _config.copyWith(restSeconds: seconds);
    notifyListeners();
  }

  void setRoundCount(int count) {
    _config = _config.copyWith(roundCount: count.clamp(1, 99));
    notifyListeners();
  }

  void loadConfig(ClassicConfig config) {
    _config = config;
    notifyListeners();
  }
}
