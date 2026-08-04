import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../core/collections.dart';
import '../data/models/collection_item.dart';
import '../data/models/item_status.dart';
import '../data/models/saved_record.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/library_repository.dart';

/// Overridden in `main()` with the Hive box opened at startup.
final libraryBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('libraryBoxProvider must be overridden in main()');
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository();
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(ref.watch(libraryBoxProvider));
});

/// The catalog deck for one collection. `.family` keys it by [CollectionType]
/// so each tab caches independently.
final catalogProvider =
    FutureProvider.family<List<CollectionItem>, CollectionType>((ref, type) {
  return ref.watch(catalogRepositoryProvider).fetch(type);
});

/// Holds the whole library in memory (keyed by item id) so any screen can
/// react to a decision instantly, while writing through to Hive for
/// persistence.
class LibraryController extends Notifier<Map<String, SavedRecord>> {
  @override
  Map<String, SavedRecord> build() {
    final repo = ref.watch(libraryRepositoryProvider);
    return {for (final r in repo.all()) r.item.id: r};
  }

  LibraryRepository get _repo => ref.read(libraryRepositoryProvider);

  Future<void> decide(CollectionItem item, ItemStatus status) async {
    final now = DateTime.now();
    await _repo.setStatus(item, status, now);
    state = {
      ...state,
      item.id: SavedRecord(item: item, status: status, updatedAt: now),
    };
  }

  Future<void> remove(String id) async {
    await _repo.remove(id);
    final next = Map<String, SavedRecord>.from(state)..remove(id);
    state = next;
  }

  ItemStatus? statusOf(String id) => state[id]?.status;

  List<SavedRecord> where({CollectionType? type, ItemStatus? status}) {
    final list = state.values
        .where((r) => type == null || r.item.type == type)
        .where((r) => status == null || r.status == status)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  int count({CollectionType? type, ItemStatus? status}) =>
      where(type: type, status: status).length;
}

final libraryControllerProvider =
    NotifierProvider<LibraryController, Map<String, SavedRecord>>(
  LibraryController.new,
);
