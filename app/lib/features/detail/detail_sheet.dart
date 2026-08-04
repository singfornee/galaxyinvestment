import 'package:flutter/material.dart';

import '../../core/collections.dart';
import '../../data/models/collection_item.dart';
import '../../widgets/item_image.dart';

/// A draggable bottom sheet with the full details of an item.
class DetailSheet extends StatelessWidget {
  const DetailSheet({super.key, required this.item});

  final CollectionItem item;

  static Future<void> show(BuildContext context, CollectionItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: ItemImage(
                  type: item.type,
                  title: item.title,
                  imageUrl: item.imageUrl,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(item.title, style: theme.textTheme.headlineSmall),
            if (item.subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ],
            if (item.meta.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in item.meta.entries)
                    Chip(
                      label: Text('${entry.key}: ${entry.value}'),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(item.description, style: theme.textTheme.bodyLarge),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'From your ${CollectionConfig.of(item.type).plural} collection',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        );
      },
    );
  }
}
