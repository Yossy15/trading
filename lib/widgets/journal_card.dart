import 'package:flutter/material.dart';
import '../models/models.dart';

class JournalCard extends StatelessWidget {
  final JournalEntry entry;

  const JournalCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final gradeColor = _gradeColor(entry.grade);
    final dirColor = entry.direction == 'BUY' ? Colors.greenAccent : Colors.redAccent;
    final outcomeColor = entry.outcome == 'win'
        ? Colors.greenAccent
        : entry.outcome == 'loss'
            ? Colors.redAccent
            : Colors.white54;
    final lessonMap = entry.lessons;
    final tagList = entry.tags;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradeColor.withAlpha(15),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: gradeColor.withAlpha(40), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              _gradeBadge(entry.grade, gradeColor),
              const SizedBox(width: 8),
              _badge(entry.direction, dirColor),
              const SizedBox(width: 8),
              _badge(entry.outcome.toUpperCase(), outcomeColor),
              const Spacer(),
              Icon(Icons.timer, color: Colors.white38, size: 14),
              const SizedBox(width: 4),
              Text(entry.held, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 12),
              Text(
                'CF ${entry.confluence.toStringAsFixed(1)}',
                style: TextStyle(color: const Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Regime badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '🏷 ${_formatRegime(entry.regime)}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          const SizedBox(height: 12),
          // EN lesson
          if (lessonMap.containsKey('en'))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📝 Lesson', style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    lessonMap['en']!,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          if (lessonMap.containsKey('th')) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🇹🇭 บทเรียน', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    lessonMap['th']!,
                    style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
          // Tags
          if (tagList.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tagList.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withAlpha(15)),
                ),
                child: Text('#$t', style: const TextStyle(color: Colors.white38, fontSize: 10)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _gradeBadge(String grade, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Center(
        child: Text(grade, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.greenAccent;
      case 'B':
        return const Color(0xFFFFD700);
      case 'C':
        return Colors.orangeAccent;
      case 'D':
        return Colors.redAccent;
      default:
        return Colors.white38;
    }
  }

  String _formatRegime(String regime) {
    return regime.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }
}
