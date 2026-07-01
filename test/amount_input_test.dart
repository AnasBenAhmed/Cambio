import 'package:cambio/state/amount_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AmountInput', () {
    test('starts at zero', () {
      final a = AmountInput();
      expect(a.raw, '0');
      expect(a.value, 0);
    });

    test('first digit replaces the leading zero', () {
      final a = AmountInput();
      a.digit('5');
      expect(a.raw, '5');
    });

    test('appends subsequent digits', () {
      final a = AmountInput();
      a.digit('5');
      a.digit('0');
      expect(a.raw, '50');
      expect(a.value, 50);
    });

    test('typing zero on zero stays a single zero', () {
      final a = AmountInput();
      a.digit('0');
      expect(a.raw, '0');
    });

    test('decimal then digits build a fraction', () {
      final a = AmountInput();
      a.decimal();
      a.digit('5');
      expect(a.raw, '0.5');
      expect(a.value, 0.5);
    });

    test('only one decimal point is allowed', () {
      final a = AmountInput();
      a.digit('1');
      a.decimal();
      a.decimal();
      a.digit('2');
      expect(a.raw, '1.2');
    });

    test('backspace removes the last character', () {
      final a = AmountInput();
      a.digit('5');
      a.digit('0');
      a.backspace();
      expect(a.raw, '5');
    });

    test('backspace on a single character collapses to zero', () {
      final a = AmountInput();
      a.digit('7');
      a.backspace();
      expect(a.raw, '0');
    });

    test('clear resets to zero', () {
      final a = AmountInput();
      a.digit('1');
      a.digit('2');
      a.clear();
      expect(a.raw, '0');
    });

    test('stops accepting digits past the max length', () {
      final a = AmountInput();
      for (var i = 0; i < 20; i++) {
        a.digit('9');
      }
      final digitCount = a.raw.replaceAll('.', '').length;
      expect(digitCount, AmountInput.maxDigits);
    });
  });
}
