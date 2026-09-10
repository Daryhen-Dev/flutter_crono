import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/running_settings.dart';
import '../../providers/running_settings_provider.dart';

class RunningSettingsScreen extends StatelessWidget {
  const RunningSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RunningSettingsProvider>();
    final settings = provider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuracion Running'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SliderSetting(
            title: 'Precision maxima GPS',
            value: settings.maxAccuracyMeters,
            min: 10,
            max: 50,
            divisions: 8,
            suffix: 'm',
            onChanged: (value) =>
                _save(provider, settings.copyWith(maxAccuracyMeters: value)),
          ),
          _SliderSetting(
            title: 'Velocidad maxima humana',
            value: settings.maxHumanSpeedMps * 3.6,
            min: 15,
            max: 40,
            divisions: 10,
            suffix: 'km/h',
            onChanged: (value) => _save(
              provider,
              settings.copyWith(maxHumanSpeedMps: value / 3.6),
            ),
          ),
          _SliderSetting(
            title: 'Auto-pausa bajo velocidad',
            value: settings.autoPauseSpeedMps * 3.6,
            min: 1,
            max: 6,
            divisions: 10,
            suffix: 'km/h',
            onChanged: (value) => _save(
              provider,
              settings.copyWith(autoPauseSpeedMps: value / 3.6),
            ),
          ),
          _SliderSetting(
            title: 'Ventana de ritmo actual',
            value: settings.paceWindowMeters,
            min: 100,
            max: 500,
            divisions: 8,
            suffix: 'm',
            onChanged: (value) =>
                _save(provider, settings.copyWith(paceWindowMeters: value)),
          ),
          const SizedBox(height: 12),
          const Text(
            'V1 usa geolocator en primer plano. La capa RunningTrackingService queda aislada para reemplazarla por background tracking nativo si se decide incorporar flutter_background_geolocation u otra alternativa.',
          ),
        ],
      ),
    );
  }

  Future<void> _save(
    RunningSettingsProvider provider,
    RunningSettings settings,
  ) async {
    await provider.update(settings);
  }
}

class _SliderSetting extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final ValueChanged<double> onChanged;

  const _SliderSetting({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              label: '${value.toStringAsFixed(1)} $suffix',
              onChanged: onChanged,
            ),
            Text('${value.toStringAsFixed(1)} $suffix'),
          ],
        ),
      ),
    );
  }
}
