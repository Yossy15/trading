class Stats {
  final int totalDecisions;
  final Map<String, int> todayDecisions;
  final double holdRate;
  final double avgConfluence;
  final List<RegimeEntry> regimeDistribution;
  final int strategiesActive;

  Stats({
    required this.totalDecisions,
    required this.todayDecisions,
    required this.holdRate,
    required this.avgConfluence,
    required this.regimeDistribution,
    required this.strategiesActive,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    final todayMap = <String, int>{};
    if (json['today_decisions'] != null) {
      (json['today_decisions'] as Map<String, dynamic>).forEach((k, v) {
        todayMap[k] = (v as num).toInt();
      });
    }
    return Stats(
      totalDecisions: json['total_decisions'] ?? 0,
      todayDecisions: todayMap,
      holdRate: (json['hold_rate'] ?? 0).toDouble(),
      avgConfluence: (json['avg_confluence'] ?? 0).toDouble(),
      regimeDistribution: (json['regime_distribution'] as List? ?? [])
          .map((e) => RegimeEntry.fromJson(e))
          .toList(),
      strategiesActive: json['strategies_active'] ?? 0,
    );
  }
}

class RegimeEntry {
  final String regime;
  final int count;

  RegimeEntry({required this.regime, required this.count});

  factory RegimeEntry.fromJson(Map<String, dynamic> json) {
    return RegimeEntry(
      regime: json['market_regime'] ?? '',
      count: (json['count'] ?? 0) as int,
    );
  }
}

class StrategyScore {
  final String name;
  final int totalTrades;
  final int correct;
  final int incorrect;
  final int neutral;
  final double accuracy;
  final double weight;
  final String lastUpdated;

  StrategyScore({
    required this.name,
    required this.totalTrades,
    required this.correct,
    required this.incorrect,
    required this.neutral,
    required this.accuracy,
    required this.weight,
    required this.lastUpdated,
  });

  factory StrategyScore.fromJson(Map<String, dynamic> json) {
    return StrategyScore(
      name: json['strategy_name'] ?? '',
      totalTrades: json['total_trades'] ?? 0,
      correct: json['correct'] ?? 0,
      incorrect: json['incorrect'] ?? 0,
      neutral: json['neutral'] ?? 0,
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      lastUpdated: json['last_updated_local'] ?? '',
    );
  }
}

class Portfolio {
  final int totalTrades;
  final int wins;
  final int losses;
  final double winRate;
  final bool profitable;
  final int openPositions;
  final int streakCount;
  final String streakType;
  final List<RecentResult> recentResults;
  final List<RecentTrade> recentTrades;
  final double avgWinLossRatio;

  Portfolio({
    required this.totalTrades,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.profitable,
    required this.openPositions,
    required this.streakCount,
    required this.streakType,
    required this.recentResults,
    required this.recentTrades,
    required this.avgWinLossRatio,
  });

  int get breakevens => totalTrades - wins - losses;

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      totalTrades: json['total_trades'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      profitable: json['profitable'] ?? false,
      openPositions: json['open_positions'] ?? 0,
      streakCount: (json['streak']?['count'] ?? 0) as int,
      streakType: json['streak']?['type'] ?? '',
      recentResults: (json['recent_results'] as List? ?? [])
          .map((e) => RecentResult.fromJson(e))
          .toList(),
      recentTrades: (json['recent_trades'] as List? ?? [])
          .map((e) => RecentTrade.fromJson(e))
          .toList(),
      avgWinLossRatio: (json['avg_win_loss_ratio'] ?? 0).toDouble(),
    );
  }
}

class RecentResult {
  final String outcome;
  final String direction;

  RecentResult({required this.outcome, required this.direction});

  factory RecentResult.fromJson(Map<String, dynamic> json) {
    return RecentResult(
      outcome: json['outcome'] ?? '',
      direction: json['direction'] ?? '',
    );
  }
}

class RecentTrade {
  final String direction;
  final String outcome;
  final String openTime;
  final String closeTime;
  final int durationMin;
  final double profit;

  RecentTrade({
    required this.direction,
    required this.outcome,
    required this.openTime,
    required this.closeTime,
    required this.durationMin,
    required this.profit,
  });

  factory RecentTrade.fromJson(Map<String, dynamic> json) {
    return RecentTrade(
      direction: json['direction'] ?? '',
      outcome: json['outcome'] ?? '',
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      durationMin: json['duration_min'] ?? 0,
      profit: (json['profit'] ?? 0).toDouble(),
    );
  }
}

class JournalEntry {
  final String direction;
  final String outcome;
  final int duration;
  final String regime;
  final double confluence;
  final String grade;
  final String tagsRaw;
  final String lessonsRaw;
  final String held;

  JournalEntry({
    required this.direction,
    required this.outcome,
    required this.duration,
    required this.regime,
    required this.confluence,
    required this.grade,
    required this.tagsRaw,
    required this.lessonsRaw,
    required this.held,
  });

  List<String> get tags {
    try {
      final decoded = tagsRaw.replaceAll(RegExp(r'[\[\]"\\]'), '');
      return decoded.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, String> get lessons {
    try {
      final cleaned = lessonsRaw;
      final map = <String, String>{};
      final enMatch = RegExp(r'"en"\s*:\s*"((?:[^"\\]|\\.)*)"').firstMatch(cleaned);
      final thMatch = RegExp(r'"th"\s*:\s*"((?:[^"\\]|\\.)*)"').firstMatch(cleaned);
      if (enMatch != null) map['en'] = enMatch.group(1) ?? '';
      if (thMatch != null) map['th'] = thMatch.group(1) ?? '';
      return map;
    } catch (_) {
      return {};
    }
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      direction: json['direction'] ?? '',
      outcome: json['outcome'] ?? '',
      duration: json['duration'] ?? 0,
      regime: json['regime'] ?? '',
      confluence: (json['confluence'] ?? 0).toDouble(),
      grade: json['grade'] ?? '',
      tagsRaw: json['tags'] ?? '[]',
      lessonsRaw: json['lessons'] ?? '{}',
      held: json['held'] ?? '',
    );
  }
}

class Quote {
  final String messageEn;
  final String messageTh;
  final String category;

  Quote({required this.messageEn, required this.messageTh, required this.category});

  factory Quote.fromJson(Map<String, dynamic> json) {
    final q = json['quote'] ?? json;
    return Quote(
      messageEn: q['message_en'] ?? '',
      messageTh: q['message_th'] ?? '',
      category: q['category'] ?? '',
    );
  }
}

class Summary {
  final int id;
  final String cycleId;
  final String timestamp;
  final String timestampLocal;
  final String decision;
  final String summaryRaw;
  final double price;
  final String regime;
  final String session;
  final double confluenceBuy;
  final double confluenceSell;
  final String tfStrength;
  final int? tradeTicket;
  final bool isAi;

  Summary({
    required this.id,
    required this.cycleId,
    required this.timestamp,
    required this.timestampLocal,
    required this.decision,
    required this.summaryRaw,
    required this.price,
    required this.regime,
    required this.session,
    required this.confluenceBuy,
    required this.confluenceSell,
    required this.tfStrength,
    this.tradeTicket,
    required this.isAi,
  });

  Map<String, String> get summaryTexts {
    try {
      final map = <String, String>{};
      final enMatch = RegExp(r'"en"\s*:\s*"((?:[^"\\]|\\.)*)"').firstMatch(summaryRaw);
      final thMatch = RegExp(r'"th"\s*:\s*"((?:[^"\\]|\\.)*)"').firstMatch(summaryRaw);
      if (enMatch != null) map['en'] = enMatch.group(1) ?? '';
      if (thMatch != null) map['th'] = thMatch.group(1) ?? '';
      return map;
    } catch (_) {
      return {};
    }
  }

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      id: json['id'] ?? 0,
      cycleId: json['cycle_id'] ?? '',
      timestamp: json['timestamp'] ?? '',
      timestampLocal: json['timestamp_local'] ?? '',
      decision: json['decision'] ?? '',
      summaryRaw: json['summary'] ?? '{}',
      price: (json['price'] ?? 0).toDouble(),
      regime: json['regime'] ?? '',
      session: json['session'] ?? '',
      confluenceBuy: (json['confluence_buy'] ?? 0).toDouble(),
      confluenceSell: (json['confluence_sell'] ?? 0).toDouble(),
      tfStrength: json['tf_strength'] ?? '',
      tradeTicket: json['trade_ticket'] != null ? (json['trade_ticket'] as num).toInt() : null,
      isAi: (json['is_ai'] ?? 0) == 1,
    );
  }
}

class Candle {
  final String time;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  bool get isBullish => close >= open;

  factory Candle.fromJson(Map<String, dynamic> json) {
    return Candle(
      time: json['time'] ?? '',
      open: (json['open'] ?? 0).toDouble(),
      high: (json['high'] ?? 0).toDouble(),
      low: (json['low'] ?? 0).toDouble(),
      close: (json['close'] ?? 0).toDouble(),
      volume: (json['volume'] ?? 0) as int,
    );
  }
}
