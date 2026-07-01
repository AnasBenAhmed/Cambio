/// A single supported currency. The flag is resolved at render time via
/// `CountryFlag.fromCurrencyCode(code)`, so no country mapping is stored here.
class Currency {
  final String code; // ISO 4217, e.g. "USD"
  final String name; // "US Dollar"
  final String symbol; // "$", "€", "د.ت"
  final int decimals; // display decimals (0 for JPY, 3 for TND/KWD, else 2)

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    this.decimals = 2,
  });

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Currency($code)';
}
