import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DurationField extends StatefulWidget {
  final String label;
  final int totalSeconds;
  final ValueChanged<int> onChanged;

  const DurationField({
    super.key,
    required this.label,
    required this.totalSeconds,
    required this.onChanged,
  });

  @override
  State<DurationField> createState() => _DurationFieldState();
}

class _DurationFieldState extends State<DurationField> {
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
  void didUpdateWidget(DurationField old) {
    super.didUpdateWidget(old);
    if (old.totalSeconds != widget.totalSeconds) {
      if (_minCtrl.selectedItem != _minutes) {
        _minCtrl.jumpToItem(_minutes);
      }
      if (_secCtrl.selectedItem != _seconds) {
        _secCtrl.jumpToItem(_seconds);
      }
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (widget.label.isNotEmpty)
            Expanded(
              child:
                  Text(widget.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18)),
            ),
          if (widget.label.isEmpty) const Spacer(),
          _buildWheel(
            controller: _minCtrl,
            itemCount: 100,
            brightStyle: brightStyle,
            dimStyle: dimStyle,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(':', style: brightStyle),
          ),
          _buildWheel(
            controller: _secCtrl,
            itemCount: 60,
            brightStyle: brightStyle,
            dimStyle: dimStyle,
          ),
        ],
      ),
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
            final isSelected = controller.hasClients &&
                controller.selectedItem == index;
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
