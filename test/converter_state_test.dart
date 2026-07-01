import 'package:cambio/models/chart_range.dart';
import 'package:cambio/services/rate_service.dart';
import 'package:cambio/state/converter_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A RateService that returns a fixed rate without touching the network.
class _FakeRateService extends RateService {
  _FakeRateService(this.fixedRate);
  final double fixedRate;

  @override
  Future<RateResult> fetch(
    String from,
    String to, {
    ChartRange range = ChartRange.d1,
  }) async =>
      RateResult(rate: fixedRate);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to TND → USD', () {
    final s = ConverterState(service: _FakeRateService(0.5));
    expect(s.from.code, 'TND');
    expect(s.to.code, 'USD');
  });

  test('converted = amount × rate after refresh', () async {
    final s = ConverterState(service: _FakeRateService(0.5));
    s.tapDigit('1');
    s.tapDigit('0'); // amount = 10
    await s.refresh();

    expect(s.rate, 0.5);
    expect(s.amount, 10);
    expect(s.converted, 5.0);
  });

  test('converted is null before a rate is loaded', () {
    final s = ConverterState(service: _FakeRateService(0.5));
    s.tapDigit('5');
    expect(s.rate, isNull);
    expect(s.converted, isNull);
  });

  test('swap exchanges from and to', () async {
    final s = ConverterState(service: _FakeRateService(2));
    await s.swap();
    expect(s.from.code, 'USD');
    expect(s.to.code, 'TND');
  });

  test('keypad edits flow through to the amount', () {
    final s = ConverterState(service: _FakeRateService(1));
    s.tapDigit('4');
    s.tapDecimal();
    s.tapDigit('2');
    s.tapDigit('5'); // 4.25
    expect(s.amount, 4.25);
    s.backspace();
    expect(s.amount, 4.2);
    s.clear();
    expect(s.amount, 0);
  });
}
