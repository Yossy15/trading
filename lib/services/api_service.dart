import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String _baseUrl = 'https://pns-api.probably-anything.com';

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await http.get(Uri.parse('$_baseUrl$path'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load $path: ${response.statusCode}');
  }

  Future<Stats> fetchStats() async {
    final data = await _get('/api/public/stats');
    return Stats.fromJson(data);
  }

  Future<List<StrategyScore>> fetchPerformance() async {
    final data = await _get('/api/public/performance');
    final list = data['scores'] as List? ?? [];
    return list.map((e) => StrategyScore.fromJson(e)).toList();
  }

  Future<Portfolio> fetchPortfolio() async {
    final data = await _get('/api/public/portfolio');
    return Portfolio.fromJson(data);
  }

  Future<List<JournalEntry>> fetchJournal({int limit = 5}) async {
    final data = await _get('/api/public/journal?limit=$limit');
    final list = data['entries'] as List? ?? [];
    return list.map((e) => JournalEntry.fromJson(e)).toList();
  }

  Future<Quote> fetchQuote() async {
    final data = await _get('/api/public/quotes');
    return Quote.fromJson(data);
  }

  Future<List<Summary>> fetchSummaries({int limit = 20}) async {
    final data = await _get('/api/summaries?limit=$limit');
    final list = data['summaries'] as List? ?? [];
    return list.map((e) => Summary.fromJson(e)).toList();
  }

  Future<List<Candle>> fetchCandles({
    String tf = 'M15',
    int limit = 120,
  }) async {
    final data = await _get('/api/candles?tf=$tf&limit=$limit');
    final list = data['candles'] as List? ?? [];
    return list.map((e) => Candle.fromJson(e)).toList();
  }
}
