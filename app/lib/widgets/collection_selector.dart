import 'package:flutter/material.dart';

import '../core/collections.dart';

/// Horizontal row of choice chips for picking the active collection. Shared by
/// Discover and Library so the two tabs feel like one app.
class CollectionSelector extends StatelessWidget {
  const CollectionSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CollectionType selected;
  final ValueChanged<CollectionType> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: CollectionConfig.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final config = CollectionConfig.all[i];
          final isSelected = config.type == selected;
          return ChoiceChip(
            selected: isSelected,
            onSelected: (_) => onSelected(config.type),
            avatar: Icon(
              config.icon,
              size: 18,
              color: isSelected ? config.color : null,
            ),
            label: Text(config.plural),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
