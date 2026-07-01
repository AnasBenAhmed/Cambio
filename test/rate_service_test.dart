import 'package:cambio/models/rate_point.dart';
import 'package:cambio/services/rate_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RateService.symbolFor', () {
    test('builds the Yahoo cross-pair symbol', () {
      expect(RateService.symbolFor('TND', 'USD'), 'TNDUSD=X');
      expect(RateService.symbolFor('EUR', 'JPY'), 'EURJPY=X');
    });
  });

  group('RateService.parse', () {
    test('reads the live rate and history, skipping null gaps', () {
      const body = '''
      {"chart":{"result":[{"meta":{"regularMarketPrice":0.3393,
      "currency":"USD","symbol":"TNDUSD=X"},
      "timestamp":[1782342000,1782345600,1782349200],
      "indicators":{"quote":[{"close":[0.339,null,0.3395]}]}}],"error":null}}''';

      final result = RateService.parse(body);

      expect(result.rate, 0.3393);
      // Middle point is null (market gap) and must be skipped.
      expect(result.history.length, 2);
      expect(result.history.first.value, 0.339);
      expect(result.history.last.value, 0.3395);
    });

    test('falls back to the last close when meta price is missing', () {
      const body = '''
      {"chart":{"result":[{"meta":{},
      "timestamp":[1782342000,1782345600],
      "indicators":{"quote":[{"close":[0.30,0.31]}]}}],"error":null}}''';

      final result = RateService.parse(body);
      expect(result.rate, 0.31);
    });

    test('returns the meta rate with empty history when markets are closed', () {
      const body = '''
      {"chart":{"result":[{"meta":{"regularMarketPrice":0.3393},
      "timestamp":[],"indicators":{"quote":[{}]}}],"error":null}}''';

      final result = RateService.parse(body);
      expect(result.rate, 0.3393);
      expect(result.history, isEmpty);
    });

    test('throws when Yahoo reports an error', () {
      const body =
          '{"chart":{"result":null,"error":{"code":"Not Found","description":"No data"}}}';
      expect(() => RateService.parse(body), throwsA(isA<RateException>()));
    });

    test('throws when no rate can be resolved', () {
      const body = '''
      {"chart":{"result":[{"meta":{},"timestamp":[],
      "indicators":{"quote":[{}]}}],"error":null}}''';
      expect(() => RateService.parse(body), throwsA(isA<RateException>()));
    });
  });

  group('RateService.triangulate', () {
    RatePoint pt(int ms, double v) =>
        RatePoint(DateTime.fromMillisecondsSinceEpoch(ms), v);

    test('derives a cross rate through USD (ZAR→TND)', () {
      final fromUsd = RateResult(rate: 0.0609, history: [pt(1000, 0.06), pt(2000, 0.061)]);
      final toUsd = RateResult(rate: 0.3393, history: [pt(1000, 0.34), pt(2000, 0.339)]);

      final result = RateService.triangulate(fromUsd, toUsd);

      expect(result.rate, closeTo(0.0609 / 0.3393, 1e-12));
      expect(result.history.length, 2);
      expect(result.history.first.value, closeTo(0.06 / 0.34, 1e-12));
    });

    test('keeps only timestamp-aligned history points', () {
      final fromUsd = RateResult(rate: 1, history: [pt(1000, 0.06), pt(3000, 0.07)]);
      final toUsd = RateResult(rate: 1, history: [pt(1000, 0.34)]);

      final result = RateService.triangulate(fromUsd, toUsd);
      expect(result.history.length, 1);
      expect(result.history.first.time.millisecondsSinceEpoch, 1000);
    });

    test('throws when the TO leg rate is zero', () {
      final fromUsd = RateResult(rate: 0.06);
      final toUsd = RateResult(rate: 0);
      expect(() => RateService.triangulate(fromUsd, toUsd),
          throwsA(isA<RateException>()));
    });
  });
}
