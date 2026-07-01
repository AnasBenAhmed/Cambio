import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../theme/app_theme.dart';
import 'flag_box.dart';

/// Flag + name + "Tap to change", used for the FROM / TO slots on the
/// converter. [alignEnd] mirrors it for the right-hand (TO) slot.
class CurrencyChip extends StatelessWidget {
  final Currency currency;
  final VoidCallback onTap;
  final bool alignEnd;

  const CurrencyChip({
    super.key,
    required this.currency,
    required this.onTap,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final texts = Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          currency.code,
          style: AppText.ui(16, weight: FontWeight.w700, spacing: 0.5),
        ),
        const SizedBox(height: 2),
        Text(
          currency.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: AppText.ui(12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 1),
        Text('Tap to change', style: AppText.ui(10, color: AppColors.textFaint)),
      ],
    );

    final flag = FlagBox(currencyCode: currency.code, width: 34, height: 24, radius: 5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: alignEnd
              ? [Flexible(child: texts), const SizedBox(width: 10), flag]
              : [flag, const SizedBox(width: 10), Flexible(child: texts)],
        ),
      ),
    );
  }
}
