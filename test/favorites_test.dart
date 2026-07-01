import 'package:cambio/state/favorites_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CurrencyPair', () {
    test('serializes and deserializes round-trip', () {
      const pair = CurrencyPair('TND', 'USD');
      final restored = CurrencyPair.fromJson(pair.toJson());
      expect(restored, pair);
      expect(restored.id, 'TND/USD');
    });

    test('encode/decode a list', () {
      final list = [const CurrencyPair('TND', 'USD'), const CurrencyPair('EUR', 'GBP')];
      final decoded = FavoritesState.decode(FavoritesState.encode(list));
      expect(decoded, list);
    });

    test('equality is value-based', () {
      expect(const CurrencyPair('TND', 'USD'), const CurrencyPair('TND', 'USD'));
      expect(const CurrencyPair('TND', 'USD') == const CurrencyPair('USD', 'TND'),
          isFalse);
    });
  });

  group('FavoritesState', () {
    test('starts empty', () {
      expect(FavoritesState().pairs, isEmpty);
    });

    test('add then contains', () {
      final f = FavoritesState();
      f.add('TND', 'USD');
      expect(f.contains('TND', 'USD'), isTrue);
      expect(f.pairs.length, 1);
    });

    test('add is idempotent (no duplicates)', () {
      final f = FavoritesState();
      f.add('TND', 'USD');
      f.add('TND', 'USD');
      expect(f.pairs.length, 1);
    });

    test('toggle adds then removes', () {
      final f = FavoritesState();
      f.toggle('EUR', 'GBP');
      expect(f.contains('EUR', 'GBP'), isTrue);
      f.toggle('EUR', 'GBP');
      expect(f.contains('EUR', 'GBP'), isFalse);
    });

    test('removeAt removes the right entry', () {
      final f = FavoritesState();
      f.add('TND', 'USD');
      f.add('EUR', 'GBP');
      f.removeAt(0);
      expect(f.pairs.length, 1);
      expect(f.contains('EUR', 'GBP'), isTrue);
      expect(f.contains('TND', 'USD'), isFalse);
    });

    test('direction matters — TND/USD is not USD/TND', () {
      final f = FavoritesState();
      f.add('TND', 'USD');
      expect(f.contains('USD', 'TND'), isFalse);
    });
  });
}
