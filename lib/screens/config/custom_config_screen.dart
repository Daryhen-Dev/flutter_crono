import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/timer_type.dart';
import '../../models/custom_config.dart';
import '../../providers/custom_config_provider.dart';
import '../../providers/presets_provider.dart';

class CustomConfigScreen extends StatefulWidget {
  const CustomConfigScreen({super.key});

  @override
  State<CustomConfigScreen> createState() => _CustomConfigScreenState();
}

class _CustomConfigScreenState extends State<CustomConfigScreen> {
  int? _expandedIndex;

  void _toggle(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomConfigProvider>();
    final segments = provider.segments;

    // Total time calculation
    int totalSeconds = provider.preparationSeconds;
    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      totalSeconds += seg.roundCount * seg.workSeconds +
          (seg.roundCount > 1 ? (seg.roundCount - 1) * seg.restSeconds : 0);
      if (i < segments.length - 1) {
        totalSeconds += provider.restBetweenSeconds;
      }
    }

    // Global config indices: 0 = preparación, 1 = descanso entre bloques
    // Segment indices start at 2, each segment uses 3 indices (work, rest, rounds)
    int segmentBaseIndex(int segIdx) => 2 + segIdx * 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: segments.isEmpty ? null : () => _savePreset(context),
            tooltip: 'Guardar rutina',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ConfigCard(
            label: 'Preparación',
            value: _formatTime(provider.preparationSeconds),
            color: AppColors.preparation,
            icon: Icons.timer_outlined,
            isExpanded: _expandedIndex == 0,
            onTap: () => _toggle(0),
            child: _CenteredDurationPicker(
              totalSeconds: provider.preparationSeconds,
              onChanged: provider.setPreparation,
            ),
          ),
          const SizedBox(height: 12),
          _ConfigCard(
            label: 'Descanso entre bloques',
            value: _formatTime(provider.restBetweenSeconds),
            color: AppColors.rest,
            icon: Icons.hotel,
            isExpanded: _expandedIndex == 1,
            onTap: () => _toggle(1),
            child: _CenteredDurationPicker(
              totalSeconds: provider.restBetweenSeconds,
              onChanged: provider.setRestBetween,
            ),
          ),
          if (segments.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
          ],
          ...List.generate(segments.length, (index) {
            final segment = segments[index];
            final base = segmentBaseIndex(index);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Segment header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.work.withValues(alpha: 0.1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.dashboard_customize, color: AppColors.work, size: 20),
                          const SizedBox(width: 8),
                          Text('Bloque ${index + 1}',
                              style: Theme.of(context).textTheme.titleSmall),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => provider.removeSegment(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    // Segment fields as expandable cards
                    _InnerConfigCard(
                      label: 'Trabajo',
                      value: _formatTime(segment.workSeconds),
                      color: AppColors.work,
                      icon: Icons.fitness_center,
                      isExpanded: _expandedIndex == base,
                      onTap: () => _toggle(base),
                      child: _CenteredDurationPicker(
                        totalSeconds: segment.workSeconds,
                        onChanged: (v) =>
                            provider.updateSegment(index, segment.copyWith(workSeconds: v)),
                      ),
                    ),
                    _InnerConfigCard(
                      label: 'Descanso',
                      value: _formatTime(segment.restSeconds),
                      color: AppColors.rest,
                      icon: Icons.self_improvement,
                      isExpanded: _expandedIndex == base + 1,
                      onTap: () => _toggle(base + 1),
                      child: _CenteredDurationPicker(
                        totalSeconds: segment.restSeconds,
                        onChanged: (v) =>
                            provider.updateSegment(index, segment.copyWith(restSeconds: v)),
                      ),
                    ),
                    _InnerConfigCard(
                      label: 'Rondas',
                      value: '${segment.roundCount}',
                      color: const Color(0xFFEF5350),
                      icon: Icons.loop,
                      isExpanded: _expandedIndex == base + 2,
                      onTap: () => _toggle(base + 2),
                      child: _CenteredCounterPicker(
                        value: segment.roundCount,
                        onChanged: (v) =>
                            provider.updateSegment(index, segment.copyWith(roundCount: v.clamp(1, 99))),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              context.read<CustomConfigProvider>().addSegment(
                const CustomSegment(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Agregar bloque'),
          ),
          if (segments.isNotEmpty) ...[
            const SizedBox(height: 24),
            _TotalTimeBanner(formattedTime: _formatTime(totalSeconds)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: segments.isEmpty
                ? null
                : () => context.push('/timer', extra: TimerType.personalizado),
            child: const Text('INICIAR'),
          ),
        ],
      ),
    );
  }

  void _savePreset(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Guardar rutina'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la rutina'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final config = context.read<CustomConfigProvider>().config;
              context.read<PresetsProvider>().add(
                    name: name,
                    type: TimerType.personalizado,
                    config: config.toJson(),
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rutina guardada')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

// --- Shared widgets ---

class _ConfigCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget child;

  const _ConfigCard({
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                color: color,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontFeatures: [const FontFeature.tabularFigures()],
                              ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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

/// Inner expandable row for segment fields (no outer Card, just divider-separated)
class _InnerConfigCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget child;

  const _InnerConfigCard({
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
    return Column(
      children: [
        const Divider(height: 1),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: color,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontFeatures: [const FontFeature.tabularFigures()],
                            ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: child,
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class _CenteredDurationPicker extends StatefulWidget {
  final int totalSeconds;
  final ValueChanged<int> onChanged;

  const _CenteredDurationPicker({
    required this.totalSeconds,
    required this.onChanged,
  });

  @override
  State<_CenteredDurationPicker> createState() =>
      _CenteredDurationPickerState();
}

class _CenteredDurationPickerState extends State<_CenteredDurationPicker> {
  late FixedExtentScrollController _minCtrl;
  late FixedExtentScrollController _secCtrl;

  int get _minutes => widget.totalSeconds ~/ 60;
  int get _seconds => widget.totalSeconds % 60;

  @override
  void initState() {
    super.initState();
    _minCtrl = FixedExtentScrollController(initialItem: _minutes);
    _secCtrl = FixedExtentScrollController(initialItem: _seconds);
  }

  @override
  void didUpdateWidget(_CenteredDurationPicker old) {
    super.didUpdateWidget(old);
    if (old.totalSeconds != widget.totalSeconds) {
      if (_minCtrl.selectedItem != _minutes) _minCtrl.jumpToItem(_minutes);
      if (_secCtrl.selectedItem != _seconds) _secCtrl.jumpToItem(_seconds);
    }
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _secCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final total = _minCtrl.selectedItem * 60 + _secCtrl.selectedItem;
    widget.onChanged(total.clamp(1, 5999));
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontFeatures: [const FontFeature.tabularFigures()],
        );
    final dimStyle = baseStyle?.copyWith(color: AppColors.textDim);
    final brightStyle = baseStyle?.copyWith(color: AppColors.textPrimary);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWheel(
          controller: _minCtrl,
          itemCount: 100,
          brightStyle: brightStyle,
          dimStyle: dimStyle,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(':', style: brightStyle),
        ),
        _buildWheel(
          controller: _secCtrl,
          itemCount: 60,
          brightStyle: brightStyle,
          dimStyle: dimStyle,
        ),
      ],
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required TextStyle? brightStyle,
    required TextStyle? dimStyle,
  }) {
    return SizedBox(
      height: 120,
      width: 56,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40,
        perspective: 0.003,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        overAndUnderCenterOpacity: 0.3,
        onSelectedItemChanged: (_) => _onChanged(),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            final isSelected =
                controller.hasClients && controller.selectedItem == index;
            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: isSelected ? brightStyle : dimStyle,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CenteredCounterPicker extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const _CenteredCounterPicker({
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  @override
  State<_CenteredCounterPicker> createState() => _CenteredCounterPickerState();
}

class _CenteredCounterPickerState extends State<_CenteredCounterPicker> {
  late FixedExtentScrollController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = FixedExtentScrollController(initialItem: widget.value - widget.min);
  }

  @override
  void didUpdateWidget(_CenteredCounterPicker old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      final target = widget.value - widget.min;
      if (_ctrl.selectedItem != target) _ctrl.jumpToItem(target);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontFeatures: [const FontFeature.tabularFigures()],
        );
    final dimStyle = baseStyle?.copyWith(color: AppColors.textDim);
    final brightStyle = baseStyle?.copyWith(color: AppColors.textPrimary);
    final itemCount = widget.max - widget.min + 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 120,
          width: 56,
          child: ListWheelScrollView.useDelegate(
            controller: _ctrl,
            itemExtent: 40,
            perspective: 0.003,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            overAndUnderCenterOpacity: 0.3,
            onSelectedItemChanged: (index) {
              widget.onChanged(index + widget.min);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                final val = index + widget.min;
                final isSelected =
                    _ctrl.hasClients && _ctrl.selectedItem == index;
                return Center(
                  child: Text(
                    val.toString().padLeft(2, '0'),
                    style: isSelected ? brightStyle : dimStyle,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TotalTimeBanner extends StatelessWidget {
  final String formattedTime;

  const _TotalTimeBanner({required this.formattedTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            color: AppColors.accent,
            size: 28,
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TIEMPO TOTAL',
                style: TextStyle(
                  color: AppColors.accent.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedTime,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
