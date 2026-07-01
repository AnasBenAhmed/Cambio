import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared header for the modal screens: an X close button on the left, a
/// centered title, and an optional trailing action.
class ModalHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final Widget? trailing;

  const ModalHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          _circle(Icons.close_rounded, onClose),
          Expanded(
            child: Center(
              child: Text(title, style: AppText.ui(17, weight: FontWeight.w700)),
            ),
          ),
          trailing ?? const SizedBox(width: 46, height: 46),
        ],
      ),
    );
  }

  static Widget _circle(IconData icon, VoidCallback onTap) => Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, size: 22, color: AppColors.textPrimary),
          ),
        ),
      );
}

/// Circular trailing action button (e.g. the "+" on Favorites).
class CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const CircleAction({super.key, required this.icon, required this.onTap, this.color});

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
