import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// Itemized order summary (subtotal/tax/shipping/total). Pure UI — all
/// values are computed upstream by provider and passed in, so this widget
/// has zero business logic and is easy to snapshot-test.
class OrderSummaryCard extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;

  const OrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _SummaryRow(label: AppStrings.subtotal, value: subtotal),
          const SizedBox(height: 8),
          _SummaryRow(label: AppStrings.tax, value: tax),
          const SizedBox(height: 8),
          _SummaryRow(
            label: AppStrings.shipping,
            value: shipping,
            freeLabel: shipping == 0,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.total,
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '\u20B9 ${total.toStringAsFixed(2)}',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool freeLabel;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.freeLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Text(
          freeLabel ? AppStrings.free : '\u20B9 ${value.toStringAsFixed(2)}',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: freeLabel ? colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
