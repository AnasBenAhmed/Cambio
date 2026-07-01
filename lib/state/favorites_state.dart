import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A saved FROM→TO currency pair.
class CurrencyPair {
  final String from;
  final String to;

  const CurrencyPair(this.from, this.to);

  String get id => '$from/$to';

  Map<String, dynamic> toJson() => {'from': from, 'to': to};

  factory CurrencyPair.fromJson(Map<String, dynamic> j) =>
      CurrencyPair(j['from'] as String, j['to'] as String);

  @override
  bool operator ==(Object other) =>
      other is CurrencyPair && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// Holds the user's favorite pairs and persists them as JSON.
class FavoritesState extends ChangeNotifier {
  final List<CurrencyPair> _pairs = [];

  List<CurrencyPair> get pairs => List.unmodifiable(_pairs);

  static const _prefsKey = 'cambio.favorites';

  bool contains(String from, String to) =>
      _pairs.any((p) => p.from == from && p.to == to);

  /// Adds the pair if absent, removes it if present.
  void toggle(String from, String to) {
    final i = _pairs.indexWhere((p) => p.from == from && p.to == to);
    if (i >= 0) {
      _pairs.removeAt(i);
    } else {
      _pairs.add(CurrencyPair(from, to));
    }
    _save();
    notifyListeners();
  }

  /// Adds a pair, ignoring duplicates.
  void add(String from, String to) {
    if (!contains(from, to)) {
      _pairs.add(CurrencyPair(from, to));
      _save();
      notifyListeners();
    }
  }

  void removeAt(int index) {
    if (index >= 0 && index < _pairs.length) {
      _pairs.removeAt(index);
      _save();
      notifyListeners();
    }
  }

  // ---- pure (de)serialization, testable without the plugin ----
  static List<CurrencyPair> decode(String json) {
    final list = jsonDecode(json) as List;
    return list
        .map((e) => CurrencyPair.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String encode(List<CurrencyPair> pairs) =>
      jsonEncode(pairs.map((p) => p.toJson()).toList());

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        _pairs
          ..clear()
          ..addAll(decode(raw));
        notifyListeners();
      }
    } catch (_) {
      // No storage yet — start empty.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, encode(_pairs));
    } catch (_) {
      // Best-effort persistence.
    }
  }
}
