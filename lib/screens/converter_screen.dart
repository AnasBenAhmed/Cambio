import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/currency.dart';
import '../state/converter_state.dart';
import '../state/favorites_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/nav.dart';
import '../widgets/currency_chip.dart';
import '../widgets/keypad.dart';
import 'chart_screen.dart';
import 'currency_picker_screen.dart';
import 'favorites_screen.dart';

class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ConverterState>();
    final favorites = context.watch<FavoritesState>();
    final isFav = favorites.contains(state.from.code, state.to.code);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              favorite: isFav,
              onFavorites: () => _openFavorites(context),
              header: _Header(state: state),
              onChart: () => _openChart(context, state),
            ),
            Expanded(flex: 5, child: _Display(state: state)),
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Keypad(
                  onDigit: state.tapDigit,
                  onDecimal: state.tapDecimal,
                  onBackspace: state.backspace,
                  onClear: state.clear,
                  onSwitch: state.swap,
                ),
              ),
            ),
            _Footer(state: state),
          ],
        ),
      ),
    );
  }

  Future<void> _openFavorites(BuildContext context) async {
    final picked = await Navigator.of(context)
        .push<CurrencyPickResult>(slideUpRoute(const FavoritesScreen()));
    if (picked != null && context.mounted) {
      context.read<ConverterState>().setPair(picked.from, picked.to);
    }
  }

  void _openChart(BuildContext context, ConverterState state) {
    Navigator.of(context).push(
      slideUpRoute(ChartScreen(from: state.from, to: state.to)),
    );
  }
}

/// Result returned when a favorite pair is chosen.
class CurrencyPickResult {
  final Currency from;
  final Currency to;
  const CurrencyPickResult(this.from, this.to);
}

class _TopBar extends StatelessWidget {
  final bool favorite;
  final VoidCallback onFavorites;
  final Widget header;
  final VoidCallback onChart;

  const _TopBar({
    required this.favorite,
    required this.onFavorites,
    required this.header,
    required this.onChart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          _CircleButton(
            icon: favorite ? Icons.star_rounded : Icons.star_outline_rounded,
            color: favorite ? AppColors.gold : AppColors.textPrimary,
            onTap: onFavorites,
          ),
          Expanded(child: Center(child: header)),
          _CircleButton(icon: Icons.bar_chart_rounded, onTap: onChart),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ConverterState state;
  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.error != null) {
      return GestureDetector(
        onTap: state.refresh,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh_rounded, size: 15, color: AppColors.crimson),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                state.error!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.ui(12, color: AppColors.crimson),
              ),
            ),
          ],
        ),
      );
    }
    if (state.rate == null) {
      return Text('Updating…', style: AppText.ui(13, color: AppColors.textSecondary));
    }
    return Text(
      '1 ${state.from.code} = ${formatRate(state.rate!)} ${state.to.code}',
      style: AppText.ui(14, weight: FontWeight.w600),
    );
  }
}

class _Display extends StatelessWidget {
  final ConverterState state;
  const _Display({required this.state});

  @override
  Widget build(BuildContext context) {
    final fromText = formatInput(state.input);
    final toText = state.converted == null
        ? '—'
        : formatValue(state.converted!, state.to.decimals);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(fromText, style: AppText.display(70)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('=', style: AppText.display(38, color: AppColors.textFaint)),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    toText,
                    style: AppText.display(70, color: AppColors.gold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CurrencyChip(
                    currency: state.from,
                    onTap: () => _pick(context, isFrom: true),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textFaint, size: 22),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CurrencyChip(
                    currency: state.to,
                    alignEnd: true,
                    onTap: () => _pick(context, isFrom: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context, {required bool isFrom}) async {
    final picked = await Navigator.of(context).push<Currency>(
      slideUpRoute(
        CurrencyPickerScreen(
          title: isFrom ? 'Convert from' : 'Convert to',
          selectedCode: isFrom ? state.from.code : state.to.code,
        ),
      ),
    );
    if (picked != null && context.mounted) {
      final s = context.read<ConverterState>();
      isFrom ? s.setFrom(picked) : s.setTo(picked);
    }
  }
}

class _Footer extends StatelessWidget {
  final ConverterState state;
  const _Footer({required this.state});

  @override
  Widget build(BuildContext context) {
    final t = state.updatedAt;
    final label = t == null
        ? 'Fetching latest rate…'
        : 'Last updated ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppText.ui(11, color: AppColors.textFaint),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _CircleButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, size: 22, color: color ?? AppColors.textPrimary),
        ),
      ),
    );
  }
}
