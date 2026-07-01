/// Chart time ranges, each mapped to the Yahoo Finance `range` + `interval`
/// query parameters that produce a sensible number of points.
enum ChartRange {
  d1('1D', '1d', '5m'),
  d7('7D', '5d', '30m'),
  m1('1M', '1mo', '1d'),
  y1('1Y', '1y', '1d'),
  y2('2Y', '2y', '1wk'),
  y5('5Y', '5y', '1wk');

  const ChartRange(this.label, this.range, this.interval);

  final String label;
  final String range;
  final String interval;
}
