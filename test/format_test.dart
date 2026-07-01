import 'package:cambio/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

/// Narrow no-break space — the thousands separator used by the formatter.
const nb = ' ';

void main() {
  group('formatValue', () {
    test('zero with decimals', () {
      expect(formatValue(0, 2), '0,00');
    });

    test('thousands grouping, no decimals', () {
      expect(formatValue(1890, 0), '1${nb}890');
      expect(formatValue(1234567, 0), '1${nb}234${nb}567');
    });

    test('rounds to the requested decimals', () {
      expect(formatValue(99.999, 2), '100,00');
      expect(formatValue(0.3393, 2), '0,34');
    });

    test('groups integer part with decimals', () {
      expect(formatValue(1234.5, 2), '1${nb}234,50');
    });
  });

  group('formatInput', () {
    test('leaves a lone zero alone', () {
      expect(formatInput('0'), '0');
    });

    test('keeps a trailing decimal the user just typed', () {
      expect(formatInput('12.'), '12,');
    });

    test('groups the integer part', () {
      expect(formatInput('1000'), '1${nb}000');
      expect(formatInput('1234.5'), '1${nb}234,5');
    });
  });

  group('formatRate', () {
    test('keeps precision for small rates', () {
      expect(formatRate(0.3393), '0,3393');
    });

    test('trims trailing zeros but keeps at least two decimals', () {
      expect(formatRate(3.11), '3,11');
      expect(formatRate(300), '300,00');
    });

    test('zero', () {
      expect(formatRate(0), '0,00');
    });
  });
}
