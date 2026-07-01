/// A single (time, value) sample used to draw the history chart.
class RatePoint {
  final DateTime time;
  final double value;

  const RatePoint(this.time, this.value);

  @override
  String toString() => 'RatePoint(${time.toIso8601String()}, $value)';
}
