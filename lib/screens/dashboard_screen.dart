import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/candle_chart.dart';
import '../widgets/strategy_table.dart';
import '../widgets/portfolio_section.dart';
import '../widgets/journal_card.dart';
import '../widgets/decision_timeline.dart';
import '../gen/assets.gen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _api = ApiService();
  Timer? _dataTimer;
  Timer? _clockTimer;

  bool _loading = true;
  String? _error;

  DateTime _now = DateTime.now();

  Stats? _stats;
  List<StrategyScore> _strategies = [];
  Portfolio? _portfolio;
  List<JournalEntry> _journal = [];
  Quote? _quote;
  List<Summary> _summaries = [];
  List<Candle> _candles = [];
  String _selectedTimeframe = 'M15';

  @override
  void initState() {
    super.initState();
    _fetchAll();
    _dataTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _fetchAll(),
    );
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _dataTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    try {
      final results = await Future.wait([
        _api.fetchStats(),
        _api.fetchPerformance(),
        _api.fetchPortfolio(),
        _api.fetchJournal(),
        _api.fetchQuote(),
        _api.fetchSummaries(),
        _api.fetchCandles(tf: _selectedTimeframe),
      ]);
      if (mounted) {
        setState(() {
          _stats = results[0] as Stats;
          _strategies = results[1] as List<StrategyScore>;
          _portfolio = results[2] as Portfolio;
          _journal = results[3] as List<JournalEntry>;
          _quote = results[4] as Quote;
          _summaries = results[5] as List<Summary>;
          _candles = results[6] as List<Candle>;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _fetchCandlesOnly(String tf) async {
    setState(() => _selectedTimeframe = tf);
    try {
      final candles = await _api.fetchCandles(tf: tf);
      if (mounted) {
        setState(() {
          _candles = candles;
        });
      }
    } catch (e) {
      debugPrint('Error fetching candles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: _loading
          ? _buildLoading()
          : _error != null
          ? _buildError()
          : _buildDashboard(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Assets.images.logo.image()],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error: $_error',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() => _loading = true);
              _fetchAll();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final latestPrice = _candles.isNotEmpty ? _candles.last.close : 0.0;
    final latestSession = _summaries.isNotEmpty ? _summaries.first.session : '';
    final latestRegime = _summaries.isNotEmpty ? _summaries.first.regime : '';
    final latestDecision = _summaries.isNotEmpty
        ? _summaries.first.decision
        : '';

    return RefreshIndicator(
      onRefresh: _fetchAll,
      color: const Color(0xFFFFD700),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                _buildHeader(latestDecision),
                const SizedBox(height: 24),

                // ── Hero Row ──
                _buildHeroRow(latestPrice, latestSession, latestRegime),
                const SizedBox(height: 24),

                // ── Quote ──
                if (_quote != null) _buildQuote(),
                if (_quote != null) const SizedBox(height: 24),

                // ── Stats Cards ──
                _buildStatsGrid(),
                const SizedBox(height: 24),

                // ── Candlestick Chart ──
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    final displayCandles = isMobile && _candles.length > 60
                        ? _candles.sublist(_candles.length - 60)
                        : _candles;
                    return CandleChart(
                      candles: displayCandles,
                      selectedTimeframe: _selectedTimeframe,
                      onTimeframeChanged: _fetchCandlesOnly,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ── Bottom Sections ──
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 800) {
                      // Desktop: Grid layout
                      return Column(
                        children: [
                          SizedBox(
                            height: 600,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: StrategyTable(scores: _strategies),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _portfolio != null
                                      ? PortfolioSection(portfolio: _portfolio!)
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 600,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: _buildJournalSection()),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: DecisionTimeline(
                                    summaries: _summaries,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildRegimeSection(),
                        ],
                      );
                    }
                    // Mobile: Horizontal swipe (scroll) layout
                    final screenWidth = MediaQuery.of(context).size.width;
                    final cardWidth =
                        screenWidth * 0.85; // Take up 85% of screen width

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.swipe,
                                color: Colors.white54,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Swipe left to see more',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height:
                              600, // Fixed height to allow internal scrolling of cards
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: cardWidth,
                                  constraints: const BoxConstraints(
                                    maxHeight: 600,
                                  ),
                                  child: StrategyTable(scores: _strategies),
                                ),
                                const SizedBox(width: 16),
                                if (_portfolio != null)
                                  Container(
                                    width: cardWidth,
                                    constraints: const BoxConstraints(
                                      maxHeight: 600,
                                    ),
                                    child: PortfolioSection(
                                      portfolio: _portfolio!,
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                Container(
                                  width: cardWidth,
                                  constraints: const BoxConstraints(
                                    maxHeight: 600,
                                  ),
                                  child: _buildJournalSection(),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: cardWidth,
                                  constraints: const BoxConstraints(
                                    maxHeight: 600,
                                  ),
                                  child: DecisionTimeline(
                                    summaries: _summaries,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: cardWidth,
                                  child: _buildRegimeSection(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────
  Widget _buildHeader(String decision) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_graph, color: Colors.black, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PNS Gold Trading Bot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'AI-Powered XAUUSD Autonomous Trader',
                style: TextStyle(
                  color: Colors.white.withAlpha(100),
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // ── Time & Next Analysis ──
        if (MediaQuery.of(context).size.width >= 600)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildTimeInfo(),
          ),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.greenAccent.withAlpha(60)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'ACTIVE',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white54),
          onPressed: () {
            setState(() => _loading = true);
            _fetchAll();
          },
        ),
      ],
    );
  }

  Widget _buildTimeInfo() {
    // Calculate next M15 candle time
    final minute = _now.minute;
    final nextMinuteMarker = ((minute ~/ 15) + 1) * 15;
    final nextAnalysis = DateTime(
      _now.year,
      _now.month,
      _now.day,
      _now.hour,
      0,
    ).add(Duration(minutes: nextMinuteMarker));
    final diff = nextAnalysis.difference(_now);
    final countdown =
        '${diff.inMinutes.toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
            const Text(
              'Current Time',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Container(width: 1, height: 24, color: Colors.white.withAlpha(20)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              countdown,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
            const Text(
              'Next Analysis',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Hero Row ────────────────────────────────────────────
  Widget _buildHeroRow(double price, String session, String regime) {
    final priceChange = _candles.length >= 2
        ? _candles.last.close - _candles[_candles.length - 2].close
        : 0.0;
    final isUp = priceChange >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withAlpha(15),
            const Color(0xFFFFA500).withAlpha(8),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withAlpha(30),
          width: 1,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 20,
        children: [
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'XAUUSD',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUp ? Icons.trending_up : Icons.trending_down,
                    color: isUp ? Colors.greenAccent : Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isUp ? "+" : ""}${priceChange.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isUp ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Session & Regime
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _heroBadge('📍 ${_formatLabel(session)}', Colors.white54),
              const SizedBox(height: 8),
              _heroBadge('📊 ${_formatLabel(regime)}', const Color(0xFFFFD700)),
              const SizedBox(height: 8),
              _heroBadge(
                '🤖 ${_stats?.strategiesActive ?? 0} Strategies Active',
                Colors.white38,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ─── Quote ───────────────────────────────────────────────
  Widget _buildQuote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.withAlpha(8), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withAlpha(25)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _quote!.messageEn,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _quote!.messageTh,
                  style: TextStyle(
                    color: Colors.amber.withAlpha(180),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Grid ──────────────────────────────────────────
  Widget _buildStatsGrid() {
    final todayTotal = (_stats?.todayDecisions.values ?? [0]).fold(
      0,
      (a, b) => a + b,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth >= 900
            ? 6
            : constraints.maxWidth >= 600
            ? 3
            : 2;
        return GridView.count(
          crossAxisCount: crossCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatCard(
              icon: Icons.psychology,
              label: 'Total Decisions',
              value: '${_stats?.totalDecisions ?? 0}',
              color: const Color(0xFF64B5F6),
              subtitle: 'All Time',
            ),
            StatCard(
              icon: Icons.today,
              label: 'Today\'s Decisions',
              value: '$todayTotal',
              color: const Color(0xFFFFD700),
              subtitle:
                  'B:${_stats?.todayDecisions['BUY'] ?? 0} S:${_stats?.todayDecisions['SELL'] ?? 0} H:${_stats?.todayDecisions['HOLD'] ?? 0}',
            ),
            StatCard(
              icon: Icons.pause_circle_outline,
              label: 'Hold Rate',
              value: '${_stats?.holdRate ?? 0}%',
              color: Colors.white54,
            ),
            StatCard(
              icon: Icons.merge_type,
              label: 'Avg Confluence',
              value: '${_stats?.avgConfluence ?? 0}',
              color: Colors.purpleAccent,
            ),
            StatCard(
              icon: Icons.emoji_events,
              label: 'Win Rate',
              value: '${_portfolio?.winRate ?? 0}%',
              color: Colors.greenAccent,
              subtitle: _portfolio?.profitable == true ? '✅ Profitable' : '',
            ),
            StatCard(
              icon: Icons.open_in_new,
              label: 'Open Positions',
              value: '${_portfolio?.openPositions ?? 0}',
              color: Colors.orangeAccent,
            ),
          ],
        );
      },
    );
  }

  // ─── Journal Section ─────────────────────────────────────
  Widget _buildJournalSection() {
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
              Icon(Icons.menu_book, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text(
                'Trading Journal — Self Learning',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _journal.map((j) => JournalCard(entry: j)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Regime Distribution ─────────────────────────────────
  Widget _buildRegimeSection() {
    if (_stats == null || _stats!.regimeDistribution.isEmpty)
      return const SizedBox.shrink();
    final total = _stats!.regimeDistribution.fold(0, (a, e) => a + e.count);

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
              Icon(Icons.donut_large, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text(
                'Market Regime Distribution',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: _stats!.regimeDistribution.asMap().entries.map((
                      entry,
                    ) {
                      final colors = [
                        Colors.redAccent,
                        Colors.greenAccent,
                        const Color(0xFFFFD700),
                        Colors.purpleAccent,
                      ];
                      return PieChartSectionData(
                        value: entry.value.count.toDouble(),
                        color: colors[entry.key % colors.length],
                        title:
                            '${(entry.value.count / total * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        radius: 28,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: _stats!.regimeDistribution.asMap().entries.map((
                    entry,
                  ) {
                    final colors = [
                      Colors.redAccent,
                      Colors.greenAccent,
                      const Color(0xFFFFD700),
                      Colors.purpleAccent,
                    ];
                    final pct = (entry.value.count / total * 100)
                        .toStringAsFixed(1);
                    return Tooltip(
                      message: _formatLabel(entry.value.regime),
                      preferBelow: false,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[entry.key % colors.length],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$pct%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${entry.value.count})',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLabel(String label) {
    return label
        .split('_')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');
  }
}
