import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/product_providers.dart';

/// Horizontally scrollable row of category filter chips, including an
/// "All" chip that clears the filter. Reads/writes [selectedCategoryProvider]
/// directly, so this widget can be dropped anywhere without prop drilling.
class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryListProvider);
    final selected = ref.watch(selectedCategoryProvider);

    if (categories.isEmpty) return const SizedBox.shrink();

    final allCategories = ['', ...categories];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final label = category.isEmpty ? 'All' : _capitalize(category);
          final isSelected = selected == category;

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) {
              ref.read(selectedCategoryProvider.notifier).state = category;
            },
          );
        },
      ),
    );
  }

  String _capitalize(String text) {
    return text
        .split(' ')
        .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
