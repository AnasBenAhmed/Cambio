import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chart_range.dart';
import '../models/rate_point.dart';

/// Result of a rate lookup: the current unit rate (1 FROM in TO units) plus an
/// optional history series for the requested range.
class RateResult {
  final double rate;
  final List<RatePoint> history;

  const RateResult({required this.rate, this.history = const []});
}

/// Thrown for any user-facing failure; `message` is safe to show directly.
/// [isConnection] marks a network failure (vs. a data/404 issue) so callers can
/// skip the USD-triangulation fallback when the device is simply offline.
class RateException implements Exception {
  final String message;
  final bool isConnection;
  RateException(this.message, {this.isConnection = false});
  @override
  String toString() => message;
}

/// Talks to Yahoo Finance's public chart endpoint. Unofficial but free and
/// key-less; a browser User-Agent is required or it rejects the request.
class RateService {
  RateService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _base = 'https://query1.finance.yahoo.com/v8/finance/chart';
  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/122.0 Safari/537.36',
  };

  static String symbolFor(String from, String to) => '$from$to=X';

  Uri _url(String from, String to, ChartRange range) => Uri.parse(
        '$_base/${symbolFor(from, to)}'
        '?range=${range.range}&interval=${range.interval}',
      );

  /// Fetches the live rate (and history for [range]) for FROM→TO. If Yahoo has
  /// no direct symbol for the pair (many exotic crosses 404), falls back to
  /// triangulating through USD.
  Future<RateResult> fetch(
    String from,
    String to, {
    ChartRange range = ChartRange.d1,
  }) async {
    if (from == to) {
      return const RateResult(rate: 1);
    }
    try {
      return await _fetchDirect(from, to, range);
    } on RateException catch (e) {
      // Offline, or a USD leg itself failed — nothing to triangulate with.
      if (e.isConnection || from == 'USD' || to == 'USD') rethrow;
      final fromUsd = await _fetchDirect(from, 'USD', range);
      final toUsd = await _fetchDirect(to, 'USD', range);
      return triangulate(fromUsd, toUsd);
    }
  }

  Future<RateResult> _fetchDirect(
    String from,
    String to,
    ChartRange range,
  ) async {
    final http.Response res;
    try {
      res = await _client.get(_url(from, to, range), headers: _headers);
    } catch (_) {
      throw RateException(
        'No connection. Check your internet and try again.',
        isConnection: true,
      );
    }
    if (res.statusCode != 200) {
      throw RateException('Rates unavailable (${res.statusCode}). Try again.');
    }
    return parse(res.body);
  }

  /// Derives FROM→TO from two USD-based results:
  /// `rate = (1 FROM in USD) / (1 TO in USD)`. History is aligned by timestamp.
  static RateResult triangulate(RateResult fromUsd, RateResult toUsd) {
    if (toUsd.rate == 0) {
      throw RateException('No rate available right now.');
    }
    final rate = fromUsd.rate / toUsd.rate;
    final toByTime = <int, double>{
      for (final p in toUsd.history) p.time.millisecondsSinceEpoch: p.value,
    };
    final history = <RatePoint>[];
    for (final p in fromUsd.history) {
      final tv = toByTime[p.time.millisecondsSinceEpoch];
      if (tv != null && tv != 0) {
        history.add(RatePoint(p.time, p.value / tv));
      }
    }
    return RateResult(rate: rate, history: history);
  }

  /// Parses a Yahoo chart response body. Static + pure for easy testing.
  static RateResult parse(String body) {
    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw RateException('Unexpected response.');
    }
    final chart = decoded['chart'];
    if (chart is! Map<String, dynamic>) {
      throw RateException('Unexpected response.');
    }
    if (chart['error'] != null) {
      throw RateException('This currency pair isn\'t supported.');
    }

    final results = chart['result'];
    if (results is! List || results.isEmpty) {
      throw RateException('No data for this pair.');
    }
    final result = results.first as Map<String, dynamic>;

    final meta = result['meta'] as Map<String, dynamic>?;
    final timestamps =
        (result['timestamp'] as List?)?.whereType<num>().toList() ?? const [];

    final indicators = result['indicators'] as Map<String, dynamic>?;
    final quoteList = indicators?['quote'] as List?;
    final closes = (quoteList != null && quoteList.isNotEmpty)
        ? ((quoteList.first as Map<String, dynamic>)['close'] as List?)
        : null;

    final history = <RatePoint>[];
    if (closes != null && closes.length == timestamps.length) {
      for (var i = 0; i < closes.length; i++) {
        final c = closes[i];
        if (c is! num) continue; // null gaps (market closed) — skip
        history.add(
          RatePoint(
            DateTime.fromMillisecondsSinceEpoch(timestamps[i].toInt() * 1000),
            c.toDouble(),
          ),
        );
      }
    }

    double? rate;
    final metaPrice = meta?['regularMarketPrice'];
    if (metaPrice is num) rate = metaPrice.toDouble();
    rate ??= history.isNotEmpty ? history.last.value : null;
    if (rate == null) {
      throw RateException('No rate available right now.');
    }

    return RateResult(rate: rate, history: history);
  }

  void dispose() => _client.close();
}
