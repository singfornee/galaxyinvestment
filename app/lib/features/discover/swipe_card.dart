import 'package:flutter/material.dart';

import '../../core/collections.dart';
import '../../data/models/collection_item.dart';
import '../../widgets/item_image.dart';

/// A single full-bleed card in the Discover deck: poster with a gradient scrim
/// and the title/subtitle/description overlaid at the bottom.
class SwipeCard extends StatelessWidget {
  const SwipeCard({super.key, required this.item, this.onInfo});

  final CollectionItem item;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    final config = CollectionConfig.of(item.type);
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ItemImage(
            type: item.type,
            title: item.title,
            imageUrl: item.imageUrl,
          ),
          // Bottom scrim for legible text over any image.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypePill(config: config),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    item.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          if (onInfo != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filledTonal(
                onPressed: onInfo,
                icon: const Icon(Icons.info_outline),
                tooltip: 'Details',
              ),
            ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.config});

  final CollectionConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            config.label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
