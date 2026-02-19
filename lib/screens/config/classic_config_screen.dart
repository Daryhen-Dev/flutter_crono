import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/timer_type.dart';
import '../../providers/classic_config_provider.dart';
import '../../providers/presets_provider.dart';

class ClassicConfigScreen extends StatefulWidget {
  const ClassicConfigScreen({super.key});

  @override
  State<ClassicConfigScreen> createState() => _ClassicConfigScreenState();
}

class _ClassicConfigScreenState extends State<ClassicConfigScreen> {
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
    final provider = context.watch<ClassicConfigProvider>();
    final config = provider.config;

    // Total time = preparation + rounds * roundSeconds + (rounds - 1) * restSeconds
    final totalSeconds = config.preparationSeconds +
        config.roundCount * config.roundSeconds +
        (config.roundCount > 1 ? (config.roundCount - 1) * config.restSeconds : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clásico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: () => _savePreset(context),
            tooltip: 'Guardar rutina',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ConfigCard(
            label: 'Preparación',
            value: _formatTime(config.preparationSeconds),
            color: AppColors.preparation,
            icon: Icons.timer_outlined,
            isExpanded: _expandedIndex == 0,
            onTap: () => _toggle(0),
            child: _CenteredDurationPicker(
              totalSeconds: config.preparationSeconds,
              onChanged: provider.setPreparation,
            ),
          ),
          const SizedBox(height: 12),
          _ConfigCard(
            label: 'Tiempo de ronda',
            value: _formatTime(config.roundSeconds),
            color: AppColors.work,
            icon: Icons.fitness_center,
            isExpanded: _expandedIndex == 1,
            onTap: () => _toggle(1),
            child: _CenteredDurationPicker(
              totalSeconds: config.roundSeconds,
              onChanged: provider.setRoundSeconds,
            ),
          ),
          const SizedBox(height: 12),
          _ConfigCard(
            label: 'Tiempo de descanso',
            value: _formatTime(config.restSeconds),
            color: AppColors.rest,
            icon: Icons.self_improvement,
            isExpanded: _expandedIndex == 2,
            onTap: () => _toggle(2),
            child: _CenteredDurationPicker(
              totalSeconds: config.restSeconds,
              onChanged: provider.setRestSeconds,
            ),
          ),
          const SizedBox(height: 12),
          _ConfigCard(
            label: 'Rondas',
            value: '${config.roundCount}',
            color: const Color(0xFFEF5350),
            icon: Icons.loop,
            isExpanded: _expandedIndex == 3,
            onTap: () => _toggle(3),
            child: _CenteredCounterPicker(
              value: config.roundCount,
              onChanged: provider.setRoundCount,
            ),
          ),
          const SizedBox(height: 24),
          _TotalTimeBanner(formattedTime: _formatTime(totalSeconds)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/timer', extra: TimerType.classic),
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
              final config =
                  context.read<ClassicConfigProvider>().config;
              context.read<PresetsProvider>().add(
                    name: name,
                    type: TimerType.classic,
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
