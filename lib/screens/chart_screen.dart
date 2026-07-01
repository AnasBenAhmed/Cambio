import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/chart_range.dart';
import '../models/currency.dart';
import '../models/rate_point.dart';
import '../services/rate_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/modal_header.dart';

/// History chart for a FROM→TO pair, with selectable time ranges. Area fill
/// uses Cambio's crimson→gold gradient.
class ChartScreen extends StatefulWidget {
  final Currency from;
  final Currency to;

  const ChartScreen({super.key, required this.from, required this.to});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final RateService _service = RateService();
  ChartRange _range = ChartRange.d7;
  late Future<RateResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<RateResult> _load() =>
      _service.fetch(widget.from.code, widget.to.code, range: _range);

  void _selectRange(ChartRange range) {
    if (range == _range) return;
    setState(() {
      _range = range;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ModalHeader(
              title: '${widget.from.code} → ${widget.to.code}',
              onClose: () => Navigator.pop(context),
            ),
            _RangeTabs(selected: _range, onSelect: _selectRange),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 24, 20, 16),
                child: FutureBuilder<RateResult>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.crimson,
                          strokeWidth: 2.5,
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return _message(snap.error.toString(), retry: true);
                    }
                    final history = snap.data?.history ?? const <RatePoint>[];
                    if (history.length < 2) {
                      return _message(
                        _range == ChartRange.d1
                            ? 'Markets are closed — no intraday data for today yet.'
                            : 'Not enough data for this range.',
                      );
                    }
                    return _Chart(range: _range, history: history);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(String text, {bool retry = false}) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: AppText.ui(14, color: AppColors.textSecondary),
              ),
              if (retry) ...[
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => setState(() => _future = _load()),
                  child: Text('Retry', style: AppText.ui(14, color: AppColors.crimson)),
                ),
              ],
            ],
          ),
        ),
      );
}

class _RangeTabs extends StatelessWidget {
  final ChartRange selected;
  final ValueChanged<ChartRange> onSelect;

  const _RangeTabs({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final r in ChartRange.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(r),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: r == selected ? AppColors.surfaceHigh : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    r.label,
                    textAlign: TextAlign.center,
                    style: AppText.ui(
                      12.5,
                      weight: FontWeight.w600,
                      color: r == selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final ChartRange range;
  final List<RatePoint> history;

  const _Chart({required this.range, required this.history});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < history.length; i++)
        FlSpot(i.toDouble(), history[i].value),
    ];

    var minY = history.first.value;
    var maxY = history.first.value;
    for (final p in history) {
      if (p.value < minY) minY = p.value;
      if (p.value > maxY) maxY = p.value;
    }
    final pad = (maxY - minY) * 0.12;
    final lowY = (minY - pad);
    final highY = (maxY + pad);
    final yInterval = ((highY - lowY) / 4).clamp(1e-9, double.infinity);
    final xInterval = ((history.length - 1) / 4).clamp(1.0, double.infinity);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (history.length - 1).toDouble(),
        minY: lowY,
        maxY: highY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.hairline, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              interval: yInterval,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  formatRate(value),
                  style: AppText.ui(9.5, color: AppColors.textFaint),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                final idx = value.round();
                if (idx < 0 || idx >= history.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _bottomLabel(range, history[idx].time),
                    style: AppText.ui(9.5, color: AppColors.textFaint),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            barWidth: 2.4,
            gradient: AppColors.brandGradient,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.crimson.withValues(alpha: 0.32),
                  AppColors.gold.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _bottomLabel(ChartRange range, DateTime t) {
    switch (range) {
      case ChartRange.d1:
      case ChartRange.d7:
        return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      case ChartRange.m1:
      case ChartRange.y1:
        return '${t.day}/${t.month}';
      case ChartRange.y2:
      case ChartRange.y5:
        return '${t.month}/${t.year % 100}';
    }
  }
}
