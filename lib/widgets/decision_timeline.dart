import 'package:flutter/material.dart';
import '../models/models.dart';

class DecisionTimeline extends StatelessWidget {
  final List<Summary> summaries;

  const DecisionTimeline({super.key, required this.summaries});

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
              Icon(Icons.timeline, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text(
                'AI Decision Timeline',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 8),
              Text('LIVE', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: Column(
                children: summaries.map((s) => _buildEntry(s)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntry(Summary s) {
    final decColor = _decisionColor(s.decision);
    final texts = s.summaryTexts;
    final time = s.timestampLocal.length >= 16 ? s.timestampLocal.substring(11, 16) : s.timestampLocal;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: decColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: decColor.withAlpha(80), blurRadius: 6, spreadRadius: 1),
                    ],
                  ),
                ),
                Container(width: 1.5, height: 100, color: Colors.white.withAlpha(15)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: decColor.withAlpha(8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: decColor.withAlpha(25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _decisionBadge(s.decision, decColor),
                      const SizedBox(width: 8),
                      Text(time, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(width: 8),
                      if (s.isAi)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('🤖 AI', style: TextStyle(fontSize: 10, color: Color(0xFFFFD700))),
                        ),
                      const Spacer(),
                      Text(
                        '\$${s.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (texts.containsKey('en'))
                    Text(
                      texts['en']!,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  if (texts.containsKey('th')) ...[
                    const SizedBox(height: 4),
                    Text(
                      texts['th']!,
                      style: const TextStyle(color: Colors.white38, fontSize: 11, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _metaBadge(_formatRegime(s.regime), Icons.bar_chart, Colors.white38),
                      _metaBadge(_formatSession(s.session), Icons.access_time, Colors.white38),
                      _metaBadge('TF: ${s.tfStrength}', Icons.trending_up,
                          s.tfStrength == 'STRONG' ? Colors.greenAccent : s.tfStrength == 'MODERATE' ? const Color(0xFFFFD700) : Colors.white38),
                      if (s.confluenceBuy > 0)
                        _metaBadge('BUY cf: ${s.confluenceBuy.toStringAsFixed(1)}', Icons.arrow_upward, Colors.greenAccent),
                      if (s.confluenceSell > 0)
                        _metaBadge('SELL cf: ${s.confluenceSell.toStringAsFixed(1)}', Icons.arrow_downward, Colors.redAccent),
                    ],
                  ),
                  if (s.tradeTicket != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.withAlpha(30)),
                      ),
                      child: Text(
                        '🎯 Ticket #${s.tradeTicket}',
                        style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decisionBadge(String decision, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        decision,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _metaBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 3),
          Text(text, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }

  Color _decisionColor(String decision) {
    switch (decision) {
      case 'BUY':
        return Colors.greenAccent;
      case 'SELL':
        return Colors.redAccent;
      case 'HOLD':
      default:
        return const Color(0xFF64B5F6);
    }
  }

  String _formatRegime(String regime) {
    return regime.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  String _formatSession(String session) {
    return session.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }
}
