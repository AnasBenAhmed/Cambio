/// Number formatting for Cambio — French/Tunisian style: space thousands
/// separators, comma decimal. Deterministic (no locale data needed), so it's
/// straightforward to unit-test.
library;

const String _thin = ' '; // narrow no-break space, used for grouping

/// Groups a run of integer digits with thin-space separators every 3.
String _group(String intDigits) {
  final s = intDigits.isEmpty ? '0' : intDigits;
  final buf = StringBuffer();
  final n = s.length;
  for (var i = 0; i < n; i++) {
    if (i > 0 && (n - i) % 3 == 0) buf.write(_thin);
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Turns a canonical numeric string ("1234.56") into display form ("1 234,56").
String _groupDotString(String dotString) {
  final neg = dotString.startsWith('-');
  final s = neg ? dotString.substring(1) : dotString;
  final dot = s.indexOf('.');
  final intPart = dot >= 0 ? s.substring(0, dot) : s;
  final frac = dot >= 0 ? s.substring(dot + 1) : '';
  final grouped = _group(intPart);
  final out = frac.isEmpty ? grouped : '$grouped,$frac';
  return neg ? '-$out' : out;
}

/// Formats raw keypad input (canonical, using '.') for the big display,
/// preserving a trailing decimal the user just typed ("12." → "12,").
String formatInput(String input) {
  final neg = input.startsWith('-');
  final s = neg ? input.substring(1) : input;
  final dot = s.indexOf('.');
  String result;
  if (dot < 0) {
    result = _group(s);
  } else {
    final intPart = s.substring(0, dot);
    final frac = s.substring(dot + 1);
    result = '${_group(intPart.isEmpty ? '0' : intPart)},$frac';
  }
  return neg ? '-$result' : result;
}

/// Formats a value to a fixed number of decimals ("1 234,56").
String formatValue(double value, int decimals) =>
    _groupDotString(value.toStringAsFixed(decimals));

/// Formats a unit rate for the header ("1 TND = 0,3393 USD"). Uses up to 4/6
/// decimals, trims trailing zeros, but always keeps at least 2.
String formatRate(double value) {
  if (value == 0) return '0,00';
  final dec = value.abs() >= 1 ? 4 : 6;
  var s = value.toStringAsFixed(dec);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    final dot = s.indexOf('.');
    final fracLen = dot < 0 ? 0 : s.length - dot - 1;
    if (fracLen == 0) {
      s = '$s.00';
    } else if (fracLen == 1) {
      s = '${s}0';
    }
  }
  return _groupDotString(s);
}
