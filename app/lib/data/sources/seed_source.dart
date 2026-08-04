import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/collections.dart';
import '../models/collection_item.dart';
import 'item_source.dart';

/// Reads a curated list bundled in `assets/seed/<type>.json`.
///
/// This is the always-available fallback: it needs no network and no keys, so
/// Discover is never empty even on a fresh install with no API keys set.
class SeedSource implements ItemSource {
  SeedSource(this.type);

  final CollectionType type;

  @override
  bool get isAvailable => true;

  @override
  Future<List<CollectionItem>> fetch({int page = 1}) async {
    // Seed data is a single fixed page.
    if (page > 1) return const [];

    final raw = await rootBundle.loadString('assets/seed/${type.name}.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CollectionItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }
}
