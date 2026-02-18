import 'package:flutter/foundation.dart';
import '../models/tabata_config.dart';

class TabataConfigProvider extends ChangeNotifier {
  TabataConfig _config = const TabataConfig();

  TabataConfig get config => _config;

  void setPreparation(int seconds) {
    _config = _config.copyWith(preparationSeconds: seconds);
    notifyListeners();
  }

  void setWorkSeconds(int seconds) {
    _config = _config.copyWith(workSeconds: seconds);
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

  void setTabataCount(int count) {
    _config = _config.copyWith(tabataCount: count.clamp(1, 99));
    notifyListeners();
  }

  void setTabataRestSeconds(int seconds) {
    _config = _config.copyWith(tabataRestSeconds: seconds);
    notifyListeners();
  }

  void loadConfig(TabataConfig config) {
    _config = config;
    notifyListeners();
  }
}
