import 'dart:convert';
import 'timer_type.dart';
import 'classic_config.dart';
import 'tabata_config.dart';
import 'custom_config.dart';

class Preset {
  final String id;
  final String name;
  final TimerType type;
  final String configJson;
  final DateTime createdAt;

  const Preset({
    required this.id,
    required this.name,
    required this.type,
    required this.configJson,
    required this.createdAt,
  });

  ClassicConfig? get classicConfig {
    if (type != TimerType.classic) return null;
    return ClassicConfig.fromJson(jsonDecode(configJson) as Map<String, dynamic>);
  }

  TabataConfig? get tabataConfig {
    if (type != TimerType.tabata) return null;
    return TabataConfig.fromJson(jsonDecode(configJson) as Map<String, dynamic>);
  }

  CustomConfig? get customConfig {
    if (type != TimerType.personalizado) return null;
    return CustomConfig.fromJson(jsonDecode(configJson) as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'configJson': configJson,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Preset.fromJson(Map<String, dynamic> json) => Preset(
        id: json['id'] as String,
        name: json['name'] as String,
        type: TimerType.values.byName(json['type'] as String),
        configJson: json['configJson'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
