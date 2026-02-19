import 'package:flutter/material.dart';
import '../../../models/preset.dart';
import '../../../models/timer_type.dart';

class PresetTile extends StatelessWidget {
  final Preset preset;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PresetTile({
    super.key,
    required this.preset,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon, String summary) = _presetInfo();
    final totalMinutes = _totalMinutes();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.35),
                color.withValues(alpha: 0.12),
              ],
            ),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
            ),
          ),
          child: Stack(
            children: [
              // Background icon
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  icon,
                  size: 100,
                  color: color.withValues(alpha: 0.08),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: title + duration badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            preset.name,
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$totalMinutes min',
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Bottom row: type chip + summary + delete
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            preset.type.displayName,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            summary,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onDelete,
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.white.withValues(alpha: 0.4),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, IconData, String) _presetInfo() {
    switch (preset.type) {
      case TimerType.classic:
        final c = preset.classicConfig!;
        return (
          const Color(0xFF42A5F5),
          Icons.loop,
          '${c.roundCount} rondas / ${_fmt(c.roundSeconds)} trabajo',
        );
      case TimerType.tabata:
        final c = preset.tabataConfig!;
        final rounds = c.roundCount * c.tabataCount;
        return (
          const Color(0xFF00E676),
          Icons.flash_on,
          '$rounds intervalos / ${_fmt(c.workSeconds)} trabajo',
        );
      case TimerType.personalizado:
        final c = preset.customConfig!;
        return (
          const Color(0xFFFF9800),
          Icons.tune,
          '${c.segments.length} bloques',
        );
    }
  }

  int _totalMinutes() {
    switch (preset.type) {
      case TimerType.classic:
        final c = preset.classicConfig!;
        final total = c.preparationSeconds +
            c.roundCount * c.roundSeconds +
            (c.roundCount > 1 ? (c.roundCount - 1) * c.restSeconds : 0);
        return (total / 60).ceil();
      case TimerType.tabata:
        final c = preset.tabataConfig!;
        final total = c.preparationSeconds +
            c.tabataCount *
                (c.roundCount * c.workSeconds +
                    (c.roundCount - 1) * c.restSeconds) +
            (c.tabataCount > 1
                ? (c.tabataCount - 1) * c.tabataRestSeconds
                : 0);
        return (total / 60).ceil();
      case TimerType.personalizado:
        final c = preset.customConfig!;
        var total = c.preparationSeconds;
        for (final s in c.segments) {
          total += s.roundCount * s.workSeconds +
              (s.roundCount > 1 ? (s.roundCount - 1) * s.restSeconds : 0);
        }
        if (c.segments.length > 1) {
          total += (c.segments.length - 1) * c.restBetweenSeconds;
        }
        return (total / 60).ceil();
    }
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '${m}m';
    return '${m}m${s}s';
  }
}
