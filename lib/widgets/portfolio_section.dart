import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';

class PortfolioSection extends StatelessWidget {
  final Portfolio portfolio;

  const PortfolioSection({super.key, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha(8),
            Colors.white.withAlpha(3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text(
                'Portfolio Overview',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donut chart
              SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 45,
                        sections: [
                          PieChartSectionData(
                            value: portfolio.wins.toDouble(),
                            color: Colors.greenAccent,
                            title: '${portfolio.wins}',
                            titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            radius: 28,
                          ),
                          PieChartSectionData(
                            value: portfolio.losses.toDouble(),
                            color: Colors.redAccent,
                            title: '${portfolio.losses}',
                            titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            radius: 28,
                          ),
                          if (portfolio.breakevens > 0)
                            PieChartSectionData(
                              value: portfolio.breakevens.toDouble(),
                              color: Colors.white38,
                              title: '${portfolio.breakevens}',
                              titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                              radius: 28,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${portfolio.winRate}%',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const Text('Win Rate', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Legend + stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem('Wins', portfolio.wins, Colors.greenAccent),
                    const SizedBox(height: 8),
                    _legendItem('Losses', portfolio.losses, Colors.redAccent),
                    const SizedBox(height: 8),
                    _legendItem('Breakeven', portfolio.breakevens, Colors.white38),
                    const SizedBox(height: 16),
                    _infoRow('Total Trades', '${portfolio.totalTrades}'),
                    _infoRow('Open Positions', '${portfolio.openPositions}'),
                    _infoRow('Streak', '${portfolio.streakCount} ${portfolio.streakType}'),
                    _infoRow('Avg W/L Ratio', portfolio.avgWinLossRatio.toStringAsFixed(2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Recent Trades', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          // Recent results row
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: portfolio.recentResults.map((r) => _resultDot(r)).toList(),
          ),
          const SizedBox(height: 16),
          // Trades list
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: Column(
                children: portfolio.recentTrades.map((t) => _tradeRow(t)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text('$label: $value', style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _resultDot(RecentResult r) {
    final color = r.outcome == 'win'
        ? Colors.greenAccent
        : r.outcome == 'loss'
            ? Colors.redAccent
            : Colors.white38;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Center(
        child: Text(
          r.direction[0],
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _tradeRow(RecentTrade t) {
    final isWin = t.outcome == 'win';
    final isLoss = t.outcome == 'loss';
    final color = isWin ? Colors.greenAccent : isLoss ? Colors.redAccent : Colors.white54;
    final profitStr = t.profit >= 0 ? '+${t.profit.toStringAsFixed(2)}' : t.profit.toStringAsFixed(2);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(20)),
      ),
      child: Row(
        children: [
          _directionBadge(t.direction),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.openTime.length >= 16 ? t.openTime.substring(5) : t.openTime,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text('${t.durationMin} min', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          _outcomeBadge(t.outcome),
          const SizedBox(width: 10),
          Text(
            profitStr,
            style: TextStyle(
              color: t.profit >= 0 ? Colors.greenAccent : Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _directionBadge(String dir) {
    final isBuy = dir == 'BUY';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isBuy ? Colors.greenAccent : Colors.redAccent).withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        dir,
        style: TextStyle(
          color: isBuy ? Colors.greenAccent : Colors.redAccent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _outcomeBadge(String outcome) {
    final color = outcome == 'win'
        ? Colors.greenAccent
        : outcome == 'loss'
            ? Colors.redAccent
            : Colors.white54;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        outcome.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
