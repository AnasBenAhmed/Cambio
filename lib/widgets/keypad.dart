import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The full-bleed converter keypad: 3 digit columns + an action column
/// (clear-all, delete-last, switch). Rounded luxe tiles on the brand surface,
/// with the Switch key carrying the crimson→gold gradient.
class Keypad extends StatelessWidget {
  final void Function(String digit) onDigit;
  final VoidCallback onDecimal;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onSwitch;

  const Keypad({
    super.key,
    required this.onDigit,
    required this.onDecimal,
    required this.onBackspace,
    required this.onClear,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _digitRow(const ['7', '8', '9']),
              _digitRow(const ['4', '5', '6']),
              _digitRow(const ['1', '2', '3']),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _KeyCell(label: ',', onTap: onDecimal)),
                    Expanded(
                      flex: 2,
                      child: _KeyCell(label: '0', onTap: () => onDigit('0')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _KeyCell(
                  icon: Icons.delete_outline_rounded,
                  iconColor: AppColors.crimson,
                  onTap: onClear,
                ),
              ),
              Expanded(
                child: _KeyCell(
                  icon: Icons.backspace_outlined,
                  iconColor: AppColors.textSecondary,
                  onTap: onBackspace,
                ),
              ),
              Expanded(
                flex: 2,
                child: _KeyCell(
                  icon: Icons.swap_vert_rounded,
                  label: 'Switch',
                  gradient: true,
                  onTap: onSwitch,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _digitRow(List<String> digits) => Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final d in digits)
              Expanded(child: _KeyCell(label: d, onTap: () => onDigit(d))),
          ],
        ),
      );
}

class _KeyCell extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color? iconColor;
  final bool gradient;
  final VoidCallback onTap;

  const _KeyCell({
    this.label,
    this.icon,
    this.iconColor,
    this.gradient = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (icon != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: gradient ? Colors.white : (iconColor ?? AppColors.textPrimary),
          ),
          if (label != null) ...[
            const SizedBox(height: 5),
            Text(
              label!,
              style: AppText.ui(12, color: Colors.white, weight: FontWeight.w600),
            ),
          ],
        ],
      );
    } else {
      content = Text(
        label ?? '',
        style: AppText.display(40, color: AppColors.textPrimary),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        color: gradient ? Colors.transparent : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: gradient
              ? const BoxDecoration(gradient: AppColors.brandGradient)
              : null,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.crimson.withValues(alpha: 0.18),
            highlightColor: AppColors.crimson.withValues(alpha: 0.06),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
