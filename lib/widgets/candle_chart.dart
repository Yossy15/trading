import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import 'package:shimmer/shimmer.dart';

class CandleChart extends StatefulWidget {
  final List<Candle> candles;
  final String selectedTimeframe;
  final ValueChanged<String> onTimeframeChanged;

  const CandleChart({
    super.key,
    required this.candles,
    required this.selectedTimeframe,
    required this.onTimeframeChanged,
  });

  @override
  State<CandleChart> createState() => _CandleChartState();
}

class _CandleChartState extends State<CandleChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.candles.isEmpty) {
      return _buildLoading();
    }

    final minLow = widget.candles
        .map((c) => c.low)
        .reduce((a, b) => a < b ? a : b);
    final maxHigh = widget.candles
        .map((c) => c.high)
        .reduce((a, b) => a > b ? a : b);
    final range = maxHigh - minLow;
    final padding = range * 0.05;
    final minY = minLow - padding;
    final maxY = maxHigh + padding;

    String _formatAxisTime(String time) {
      if (time.length < 16) return time;
      if (widget.selectedTimeframe == 'D1' ||
          widget.selectedTimeframe == 'W1') {
        return time.substring(5, 10); // MM-DD
      } else {
        return time.substring(11, 16); // HH:mm
      }
    }

    String _formatTooltipTime(String time) {
      if (time.length < 16) return time;
      if (widget.selectedTimeframe == 'D1' ||
          widget.selectedTimeframe == 'W1') {
        return time.substring(0, 10); // YYYY-MM-DD
      } else {
        return time.substring(5, 16); // MM-DD HH:mm
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withAlpha(8), Colors.white.withAlpha(3)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.candlestick_chart,
                color: Color(0xFFFFD700),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'XAUUSD — ${widget.selectedTimeframe} Candlestick Chart',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildPriceBadge(),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimeframeSelector(),
          const SizedBox(height: 16),
          SizedBox(
            height: 350,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth =
                    constraints.maxWidth - 60; // 60 is for rightTitles
                final candleWidth = availableWidth / widget.candles.length;
                final bodyWidth = (candleWidth * 0.7).clamp(1.5, 6.0);
                final wickWidth = (candleWidth * 0.1).clamp(0.5, 1.5);

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    minY: minY,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchCallback: (event, response) {
                        if (!mounted) return;
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.spot == null) {
                            _touchedIndex = -1;
                          } else {
                            _touchedIndex = response.spot!.touchedBarGroupIndex;
                          }
                        });
                      },
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final c = widget.candles[group.x];
                          return BarTooltipItem(
                            '${_formatTooltipTime(c.time)}\nO: ${c.open.toStringAsFixed(1)}\nH: ${c.high.toStringAsFixed(1)}\nL: ${c.low.toStringAsFixed(1)}\nC: ${c.close.toStringAsFixed(1)}',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= widget.candles.length)
                              return const SizedBox.shrink();
                            if (idx % 20 != 0) return const SizedBox.shrink();
                            final time = widget.candles[idx].time;
                            final label = _formatAxisTime(time);
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 9,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: range / 6,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withAlpha(15),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildBarGroups(
                      minY,
                      maxY,
                      bodyWidth,
                      wickWidth,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Row(
      children: ['M5', 'M15', 'H1', 'D1'].map((tf) {
        final isSelected = tf == widget.selectedTimeframe;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => widget.onTimeframeChanged(tf),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFD700).withAlpha(40)
                    : Colors.white.withAlpha(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFFD700)
                      : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tf,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFD700) : Colors.white54,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceBadge() {
    if (widget.candles.isEmpty) return const SizedBox.shrink();
    final last = widget.candles.last;
    final change = last.close - last.open;
    final isUp = change >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUp
            ? Colors.greenAccent.withAlpha(30)
            : Colors.redAccent.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUp
              ? Colors.greenAccent.withAlpha(80)
              : Colors.redAccent.withAlpha(80),
        ),
      ),
      child: Text(
        '${last.close.toStringAsFixed(2)} ${isUp ? "▲" : "▼"} ${change.abs().toStringAsFixed(2)}',
        style: TextStyle(
          color: isUp ? Colors.greenAccent : Colors.redAccent,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    double minY,
    double maxY,
    double bodyWidth,
    double wickWidth,
  ) {
    return List.generate(widget.candles.length, (i) {
      final c = widget.candles[i];
      final isUp = c.close >= c.open;
      final bodyTop = isUp ? c.close : c.open;
      final bodyBottom = isUp ? c.open : c.close;
      final color = isUp ? const Color(0xFF4CAF50) : const Color(0xFFf44336);
      final wickColor = color.withAlpha(120);

      return BarChartGroupData(
        x: i,
        groupVertically: true,
        barRods: [
          BarChartRodData(
            fromY: c.low,
            toY: c.high,
            width: wickWidth,
            color: wickColor,
            borderRadius: BorderRadius.zero,
            backDrawRodData: BackgroundBarChartRodData(
              show: i == _touchedIndex,
              toY: maxY,
              fromY: minY,
              color: Colors.white.withAlpha(100),
            ),
          ),
          BarChartRodData(
            fromY: bodyBottom,
            toY: bodyTop,
            width: bodyWidth,
            color: color,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withAlpha(20),
      highlightColor: Colors.white.withAlpha(50),
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(128),
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(color: Colors.white.withAlpha(20), width: 1),
        ),
      ),
    );
  }
}
