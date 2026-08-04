import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/collections.dart';

/// Poster/thumbnail for an item. Falls back to a themed gradient with an
/// initial when there's no image URL (common for cities and attractions) or
/// the network fetch fails — so a card is never blank.
class ItemImage extends StatelessWidget {
  const ItemImage({
    super.key,
    required this.type,
    required this.title,
    this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final CollectionType type;
  final String title;
  final String? imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _Placeholder(type: type, title: title);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: fit,
      placeholder: (_, __) => _Placeholder(type: type, title: title),
      errorWidget: (_, __, ___) => _Placeholder(type: type, title: title),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.type, required this.title});

  final CollectionType type;
  final String title;

  @override
  Widget build(BuildContext context) {
    final config = CollectionConfig.of(type);
    final trimmed = title.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.color,
            Color.lerp(config.color, Colors.black, 0.35)!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, color: Colors.white70, size: 56),
            const SizedBox(height: 12),
            Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
