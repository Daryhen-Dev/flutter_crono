import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/timer_type.dart';
import '../../models/workout_record.dart';
import '../../providers/history_provider.dart';
import 'widgets/period_selector.dart';
import 'widgets/type_filter_chips.dart';
import 'widgets/summary_card.dart';
import 'widgets/workout_day_group.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  PeriodType _periodType = PeriodType.week;
  TimerType? _typeFilter;
  int _offset = 0; // 0 = current period, -1 = previous, etc.

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final now = DateTime.now();

    final records = _getRecords(provider, now);
    final filtered = HistoryProvider.filterByType(records, _typeFilter);
    final summary = provider.getSummary(filtered);

    // Group by day
    final grouped = _groupByDay(filtered);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_periodTitle(now)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _offset--),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _offset < 0 ? () => setState(() => _offset++) : null,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          PeriodSelector(
            selected: _periodType,
            onChanged: (p) => setState(() {
              _periodType = p;
              _offset = 0;
            }),
          ),
          const SizedBox(height: 8),
          TypeFilterChips(
            selected: _typeFilter,
            onChanged: (t) => setState(() => _typeFilter = t),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SummaryCard(
              totalSessions: summary['totalSessions'] as int,
              totalSeconds: summary['totalSeconds'] as int,
              avgSeconds: summary['avgSeconds'] as int,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history,
                            size: 48, color: AppColors.textDim),
                        const SizedBox(height: 8),
                        Text('Sin entrenamientos',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textDim)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final entry = grouped[index];
                      return WorkoutDayGroup(
                        label: entry.key,
                        records: entry.value,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<WorkoutRecord> _getRecords(HistoryProvider provider, DateTime now) {
    switch (_periodType) {
      case PeriodType.week:
        final ref = now.add(Duration(days: 7 * _offset));
        return provider.getWeek(ref);
      case PeriodType.month:
        final date = DateTime(now.year, now.month + _offset);
        return provider.getMonth(date.year, date.month);
      case PeriodType.year:
        return provider.getYear(now.year + _offset);
    }
  }

  String _periodTitle(DateTime now) {
    switch (_periodType) {
      case PeriodType.week:
        final ref = now.add(Duration(days: 7 * _offset));
        final monday = ref.subtract(Duration(days: ref.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        return '${_shortDate(monday)} - ${_shortDate(sunday)}';
      case PeriodType.month:
        final date = DateTime(now.year, now.month + _offset);
        return '${_monthName(date.month)} ${date.year}';
      case PeriodType.year:
        return '${now.year + _offset}';
    }
  }

  List<MapEntry<String, List<WorkoutRecord>>> _groupByDay(
      List<WorkoutRecord> records) {
    final map = <String, List<WorkoutRecord>>{};
    for (final r in records) {
      final key = _dayLabel(r.completedAt);
      map.putIfAbsent(key, () => []).add(r);
    }
    return map.entries.toList();
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return _shortDate(date);
  }

  String _shortDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const names = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return names[month];
  }
}
