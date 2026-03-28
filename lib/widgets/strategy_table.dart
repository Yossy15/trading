import 'package:flutter/material.dart';
import '../models/models.dart';
import 'package:shimmer/shimmer.dart';

class StrategyTable extends StatelessWidget {
  final List<StrategyScore> scores;

  const StrategyTable({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    final sorted = List<StrategyScore>.from(scores)
      ..sort((a, b) => b.accuracy.compareTo(a.accuracy));

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
          const Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text(
                'Strategy Performance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Strategy',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Accuracy',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Progress',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'W',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'L',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Weight',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: scores.isEmpty
                  ? _buildEmptyState()
                  : Column(children: sorted.map((s) => _buildRow(s)).toList()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(StrategyScore s) {
    final accColor = s.accuracy >= 70
        ? Colors.greenAccent
        : s.accuracy >= 50
        ? const Color(0xFFFFD700)
        : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(10))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              _formatName(s.name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${s.accuracy.toStringAsFixed(1)}%',
              style: TextStyle(
                color: accColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (s.accuracy / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.white.withAlpha(15),
                color: accColor,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${s.correct}',
              style: const TextStyle(color: Colors.greenAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${s.incorrect}',
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _weightColor(s.weight).withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s.weight.toStringAsFixed(2),
                    style: TextStyle(
                      color: _weightColor(s.weight),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _weightColor(double w) {
    if (w >= 0.8) return Colors.greenAccent;
    if (w >= 0.5) return const Color(0xFFFFD700);
    return Colors.white54;
  }

  String _formatName(String name) {
    return name
        .split('_')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');
  }

  _buildEmptyState() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withAlpha(15),
      highlightColor: Colors.white.withAlpha(30),
      child: Column(
        children: [
          for (int i = 0; i < 10; i++) ...[
            const SizedBox(height: 14),
            Shimmer.fromColors(
              baseColor: Colors.white.withAlpha(20),
              highlightColor: Colors.white.withAlpha(50),
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  // border: Border.all(color: Colors.white.withAlpha(20), width: 1),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
