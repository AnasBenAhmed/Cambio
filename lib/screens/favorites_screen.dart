import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/currencies.dart';
import '../models/currency.dart';
import '../services/rate_service.dart';
import '../state/converter_state.dart';
import '../state/favorites_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/flag_box.dart';
import '../widgets/modal_header.dart';
import 'converter_screen.dart';

/// Saved pairs with live mini-rates. Pops with a [CurrencyPickResult] when a
/// row is tapped; the "+" saves the converter's current pair.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final RateService _service = RateService();

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesState>();
    final converter = context.read<ConverterState>();
    final pairs = favorites.pairs;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ModalHeader(
              title: 'Favorites',
              onClose: () => Navigator.pop(context),
              trailing: CircleAction(
                icon: Icons.add_rounded,
                onTap: () =>
                    favorites.add(converter.from.code, converter.to.code),
              ),
            ),
            Expanded(
              child: pairs.isEmpty
                  ? _empty()
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: pairs.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: AppColors.hairline,
                        indent: 68,
                      ),
                      itemBuilder: (context, i) {
                        final pair = pairs[i];
                        final from = kCurrencyByCode[pair.from];
                        final to = kCurrencyByCode[pair.to];
                        if (from == null || to == null) {
                          return const SizedBox.shrink();
                        }
                        return _FavoriteTile(
                          key: ValueKey(pair.id),
                          service: _service,
                          from: from,
                          to: to,
                          onTap: () => Navigator.pop(
                            context,
                            CurrencyPickResult(from, to),
                          ),
                          onDelete: () => favorites.removeAt(i),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_outline_rounded,
                  size: 44, color: AppColors.textFaint),
              const SizedBox(height: 14),
              Text(
                'No favorites yet',
                style: AppText.ui(16, weight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap + to save the pair you\'re converting.',
                textAlign: TextAlign.center,
                style: AppText.ui(13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
}

class _FavoriteTile extends StatelessWidget {
  final RateService service;
  final Currency from;
  final Currency to;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FavoriteTile({
    super.key,
    required this.service,
    required this.from,
    required this.to,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss-${from.code}-${to.code}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        color: AppColors.crimson.withValues(alpha: 0.85),
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        leading: FlagBox(currencyCode: to.code, width: 38, height: 27, radius: 5),
        title: FutureBuilder<RateResult>(
          future: service.fetch(from.code, to.code),
          builder: (context, snap) {
            final String rateText;
            if (snap.hasData) {
              rateText = formatRate(snap.data!.rate);
            } else if (snap.hasError) {
              rateText = '—';
            } else {
              rateText = '…';
            }
            return RichText(
              text: TextSpan(
                style: AppText.ui(15, weight: FontWeight.w600),
                children: [
                  TextSpan(text: '1 ${from.code}  '),
                  const TextSpan(
                    text: '→',
                    style: TextStyle(color: AppColors.textFaint),
                  ),
                  TextSpan(
                    text: '  $rateText ${to.code}',
                    style: const TextStyle(color: AppColors.gold),
                  ),
                ],
              ),
            );
          },
        ),
        subtitle: Text(
          '${from.name} → ${to.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.ui(12, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
