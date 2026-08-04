import 'package:flutter/material.dart';

import '../../core/collections.dart';
import '../../data/models/collection_item.dart';
import '../../widgets/item_image.dart';

/// A full-bleed card in the Discover deck: the image fills the whole screen
/// with a top and bottom scrim so the overlaid controls and text stay legible.
/// Tapping anywhere opens the details sheet.
class SwipeCard extends StatelessWidget {
  const SwipeCard({super.key, required this.item, this.onTap});

  final CollectionItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final config = CollectionConfig.of(item.type);
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ItemImage(
            type: item.type,
            title: item.title,
            imageUrl: item.imageUrl,
          ),
          // Top scrim keeps the floating selector/badge readable.
          const Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor: 0.22,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          // Bottom scrim behind the title/description and action buttons.
          const Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.55,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
            ),
          ),
          // Title block — sits above the action bar (which the deck overlays).
          Positioned(
            left: 24,
            right: 24,
            bottom: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypePill(config: config),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.05,
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 17),
                  ),
                ],
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.touch_app_outlined,
                        size: 15, color: Colors.white.withValues(alpha: 0.6)),
                    const SizedBox(width: 6),
                    Text(
                      'Tap for details',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            config.label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
