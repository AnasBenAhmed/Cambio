import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/currencies.dart';
import '../models/currency.dart';
import '../services/rate_service.dart';
import 'amount_input.dart';

/// Drives the converter screen: the two selected currencies, the keypad input,
/// the live rate, and load/error state. Persists the last-used pair.
class ConverterState extends ChangeNotifier {
  ConverterState({RateService? service})
      : _service = service ?? RateService();

  final RateService _service;
  final AmountInput _amount = AmountInput();

  Currency _from = kCurrencyByCode['TND']!;
  Currency _to = kCurrencyByCode['USD']!;
  double? _rate;
  bool _loading = false;
  String? _error;
  DateTime? _updatedAt;

  Currency get from => _from;
  Currency get to => _to;
  String get input => _amount.raw;
  double get amount => _amount.value;
  double? get rate => _rate;
  double? get converted => _rate == null ? null : _amount.value * _rate!;
  bool get loading => _loading;
  String? get error => _error;
  DateTime? get updatedAt => _updatedAt;

  static const _prefsFrom = 'cambio.from';
  static const _prefsTo = 'cambio.to';

  /// Restores the last pair (if any) and fetches the current rate.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final f = prefs.getString(_prefsFrom);
      final t = prefs.getString(_prefsTo);
      if (f != null && kCurrencyByCode.containsKey(f)) _from = kCurrencyByCode[f]!;
      if (t != null && kCurrencyByCode.containsKey(t)) _to = kCurrencyByCode[t]!;
    } catch (_) {
      // First run or no storage — keep defaults.
    }
    await refresh();
  }

  // ---- keypad ----
  void tapDigit(String d) {
    _amount.digit(d);
    notifyListeners();
  }

  void tapDecimal() {
    _amount.decimal();
    notifyListeners();
  }

  void backspace() {
    _amount.backspace();
    notifyListeners();
  }

  void clear() {
    _amount.clear();
    notifyListeners();
  }

  // ---- currency selection ----
  Future<void> setFrom(Currency c) async {
    if (c == _from) return;
    _from = c;
    notifyListeners();
    await refresh();
  }

  Future<void> setTo(Currency c) async {
    if (c == _to) return;
    _to = c;
    notifyListeners();
    await refresh();
  }

  Future<void> swap() async {
    final tmp = _from;
    _from = _to;
    _to = tmp;
    notifyListeners();
    await refresh();
  }

  /// Sets both currencies at once (e.g. picking a saved favorite), refreshing
  /// only once.
  Future<void> setPair(Currency from, Currency to) async {
    if (from == _from && to == _to) return;
    _from = from;
    _to = to;
    notifyListeners();
    await refresh();
  }

  /// Fetches the current rate for the selected pair.
  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _service.fetch(_from.code, _to.code);
      _rate = res.rate;
      _updatedAt = DateTime.now();
      _save();
    } on RateException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong. Try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsFrom, _from.code);
      await prefs.setString(_prefsTo, _to.code);
    } catch (_) {
      // Non-fatal — persistence is best-effort.
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
