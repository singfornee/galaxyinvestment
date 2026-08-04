import 'package:hive/hive.dart';

import '../../core/collections.dart';
import '../models/collection_item.dart';
import '../models/item_status.dart';
import '../models/saved_record.dart';

/// The user's private library, persisted locally with Hive.
///
/// Records are keyed by [CollectionItem.id] so re-deciding an item overwrites
/// its previous status rather than duplicating it. Everything is stored as
/// plain JSON maps — no generated adapters — which keeps the schema flexible
/// and the storage layer dependency-light.
class LibraryRepository {
  LibraryRepository(this._box);

  final Box _box;

  static const String boxName = 'library';

  SavedRecord? record(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return SavedRecord.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  ItemStatus? statusOf(String id) => record(id)?.status;

  Future<void> setStatus(
    CollectionItem item,
    ItemStatus status,
    DateTime now,
  ) async {
    final rec = SavedRecord(item: item, status: status, updatedAt: now);
    await _box.put(item.id, rec.toJson());
  }

  Future<void> remove(String id) => _box.delete(id);

  /// All records, optionally filtered by collection and/or status, newest
  /// decision first.
  List<SavedRecord> all({CollectionType? type, ItemStatus? status}) {
    final records = _box.values
        .map((raw) => SavedRecord.fromJson(Map<String, dynamic>.from(raw as Map)))
        .where((r) => type == null || r.item.type == type)
        .where((r) => status == null || r.status == status)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return records;
  }

  int count({CollectionType? type, ItemStatus? status}) =>
      all(type: type, status: status).length;
}
