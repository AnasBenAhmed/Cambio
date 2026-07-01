import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

/// Rounded rectangular flag for a currency code, resolved via
/// `CountryFlag.fromCurrencyCode` (e.g. TND → 🇹🇳, EUR → 🇪🇺).
class FlagBox extends StatelessWidget {
  final String currencyCode;
  final double width;
  final double height;
  final double radius;

  const FlagBox({
    super.key,
    required this.currencyCode,
    this.width = 40,
    this.height = 30,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CountryFlag.fromCurrencyCode(
        currencyCode,
        theme: ImageTheme(
          width: width,
          height: height,
          shape: RoundedRectangle(radius),
        ),
      ),
    );
  }
}
