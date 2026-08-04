import '../models/collection_item.dart';

/// A provider of catalog items for one collection.
///
/// Implementations wrap a public API (TMDB, Google Books, …). They should
/// throw on failure — the repository layer decides how to fall back — rather
/// than swallowing errors and returning an empty list.
abstract class ItemSource {
  /// Whether this source is usable right now (e.g. an API key is present).
  /// When false the repository skips straight to seed data.
  bool get isAvailable;

  /// Fetch a page of items. [page] is 1-based.
  Future<List<CollectionItem>> fetch({int page = 1});
}
