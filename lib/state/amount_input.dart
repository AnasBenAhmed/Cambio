/// Pure keypad-driven numeric input. Holds a canonical string (using '.' as the
/// decimal point) and exposes the operations the keypad triggers. No Flutter or
/// plugin dependencies, so it's trivially unit-testable.
class AmountInput {
  AmountInput([String initial = '0']) : _raw = initial;

  String _raw;

  /// Max significant digits, guarding against overflow / silly input.
  static const int maxDigits = 12;

  String get raw => _raw;

  double get value => double.tryParse(_raw) ?? 0;

  /// Appends a single digit ('0'–'9'), replacing a lone leading zero.
  void digit(String d) {
    final digitCount = _raw.replaceAll('.', '').replaceAll('-', '').length;
    if (digitCount >= maxDigits) return;
    if (_raw == '0') {
      _raw = d;
    } else {
      _raw += d;
    }
  }

  /// Adds a decimal point if there isn't one already ("0" → "0.").
  void decimal() {
    if (!_raw.contains('.')) _raw = '$_raw.';
  }

  /// Deletes the last character, collapsing to "0" when empty.
  void backspace() {
    if (_raw.length <= 1) {
      _raw = '0';
    } else {
      _raw = _raw.substring(0, _raw.length - 1);
      if (_raw.isEmpty || _raw == '-') _raw = '0';
    }
  }

  /// Resets to "0".
  void clear() => _raw = '0';
}
