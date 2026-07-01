import 'package:flutter/material.dart';

import '../data/currencies.dart';
import '../models/currency.dart';
import '../theme/app_theme.dart';
import '../widgets/flag_box.dart';
import '../widgets/modal_header.dart';

/// Searchable list of currencies. Pops with the chosen [Currency].
class CurrencyPickerScreen extends StatefulWidget {
  final String title;
  final String? selectedCode;

  const CurrencyPickerScreen({super.key, required this.title, this.selectedCode});

  @override
  State<CurrencyPickerScreen> createState() => _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState extends State<CurrencyPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final items = q.isEmpty
        ? kCurrencies
        : kCurrencies
            .where((c) =>
                c.code.toLowerCase().contains(q) ||
                c.name.toLowerCase().contains(q))
            .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ModalHeader(title: widget.title, onClose: () => Navigator.pop(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: AppText.ui(15),
                cursorColor: AppColors.crimson,
                decoration: InputDecoration(
                  hintText: 'Search name or code',
                  hintStyle: AppText.ui(14, color: AppColors.textFaint),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text('No match',
                          style: AppText.ui(14, color: AppColors.textFaint)),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: AppColors.hairline,
                        indent: 68,
                      ),
                      itemBuilder: (context, i) {
                        final c = items[i];
                        final selected = c.code == widget.selectedCode;
                        return ListTile(
                          onTap: () => Navigator.pop(context, c),
                          leading: FlagBox(
                              currencyCode: c.code, width: 38, height: 27, radius: 5),
                          title: Text(c.code,
                              style: AppText.ui(15, weight: FontWeight.w700)),
                          subtitle: Text(c.name,
                              style: AppText.ui(12, color: AppColors.textSecondary)),
                          trailing: selected
                              ? const Icon(Icons.check_rounded, color: AppColors.gold)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
