import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/audio_settings_provider.dart';
import '../../services/audio_service.dart';

class AudioSettingsScreen extends StatefulWidget {
  const AudioSettingsScreen({super.key});

  @override
  State<AudioSettingsScreen> createState() => _AudioSettingsScreenState();
}

class _AudioSettingsScreenState extends State<AudioSettingsScreen> {
  int? _expandedIndex;

  static const _musicFiles = [
    'soundoffreedom-808-beat-486241.mp3',
    'the_mountain-sports-rock-rock-background-449412.mp3',
    'u_fqkekalnfb-break-the-apex-476114.mp3',
    'vibehorn-cozy-lofi-relax-468509.mp3',
  ];

  void _toggle(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  String _displayName(String filename) {
    // Remove extension, replace hyphens/underscores with spaces, capitalize first letter
    final name = filename
        .replaceAll(RegExp(r'\.[^.]+$'), '')
        .replaceAll(RegExp(r'[-_]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (name.isEmpty) return filename;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioSettingsProvider>();
    final settings = provider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Audio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AudioCard(
            label: 'Música de trabajo',
            value: settings.workMusic != null
                ? _displayName(settings.workMusic!)
                : 'Sin música',
            color: AppColors.work,
            icon: Icons.fitness_center,
            isExpanded: _expandedIndex == 0,
            onTap: () => _toggle(0),
            child: _MusicSelector(
              files: _musicFiles,
              selected: settings.workMusic,
              onSelected: (file) {
                provider.setWorkMusic(file);
                if (file != null) {
                  AudioService.instance.playPreview('audio/music/$file');
                }
              },
              displayName: _displayName,
            ),
          ),
          const SizedBox(height: 12),
          _AudioCard(
            label: 'Música de descanso',
            value: settings.restMusic != null
                ? _displayName(settings.restMusic!)
                : 'Sin música',
            color: AppColors.rest,
            icon: Icons.self_improvement,
            isExpanded: _expandedIndex == 1,
            onTap: () => _toggle(1),
            child: _MusicSelector(
              files: _musicFiles,
              selected: settings.restMusic,
              onSelected: (file) {
                provider.setRestMusic(file);
                if (file != null) {
                  AudioService.instance.playPreview('audio/music/$file');
                }
              },
              displayName: _displayName,
            ),
          ),
          // TODO: Tono de inicio y fin — pendiente
        ],
      ),
    );
  }
}

class _AudioCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget child;

  const _AudioCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isExpanded,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontSize: 16, color: color),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down, color: color),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _MusicSelector extends StatelessWidget {
  final List<String> files;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final String Function(String) displayName;

  const _MusicSelector({
    required this.files,
    required this.selected,
    required this.onSelected,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OptionTile(
          label: 'Sin música',
          isSelected: selected == null,
          onTap: () => onSelected(null),
        ),
        ...files.map((file) => _OptionTile(
              label: displayName(file),
              isSelected: selected == file,
              onTap: () => onSelected(file),
            )),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.accent : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.accent, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
