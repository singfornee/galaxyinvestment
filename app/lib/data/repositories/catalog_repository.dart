import '../../core/collections.dart';
import '../models/collection_item.dart';
import '../sources/api_ninjas_cities_source.dart';
import '../sources/google_books_source.dart';
import '../sources/item_source.dart';
import '../sources/opentripmap_source.dart';
import '../sources/seed_source.dart';
import '../sources/tmdb_source.dart';

/// Supplies catalog items for each collection, preferring a live API source
/// and falling back to bundled seed data whenever the API is unavailable,
/// errors, or returns nothing. This is what makes the app usable with zero
/// configuration while still upgrading cleanly once keys are added.
class CatalogRepository {
  CatalogRepository({Map<CollectionType, ItemSource>? sources})
      : _apiSources = sources ??
            {
              CollectionType.movies: TmdbSource(),
              CollectionType.books: GoogleBooksSource(),
              CollectionType.attractions: OpenTripMapSource(),
              CollectionType.cities: ApiNinjasCitiesSource(),
            };

  final Map<CollectionType, ItemSource> _apiSources;
  final Map<CollectionType, SeedSource> _seedSources = {};

  SeedSource _seed(CollectionType type) =>
      _seedSources.putIfAbsent(type, () => SeedSource(type));

  Future<List<CollectionItem>> fetch(
    CollectionType type, {
    int page = 1,
  }) async {
    final api = _apiSources[type];
    if (api != null && api.isAvailable) {
      try {
        final items = await api.fetch(page: page);
        if (items.isNotEmpty) return items;
      } catch (_) {
        // Fall through to seed on any network/parse failure.
      }
    }
    return _seed(type).fetch(page: page);
  }

  /// Whether [type] is currently backed by a live API (vs. seed only).
  bool isLive(CollectionType type) =>
      _apiSources[type]?.isAvailable ?? false;
}
