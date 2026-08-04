import 'package:curio/core/collections.dart';
import 'package:curio/data/models/collection_item.dart';
import 'package:curio/data/models/item_status.dart';
import 'package:curio/data/models/saved_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CollectionItem', () {
    test('survives a JSON round-trip', () {
      const item = CollectionItem(
        id: 'movies:42',
        type: CollectionType.movies,
        title: 'Interstellar',
        subtitle: '2014',
        imageUrl: 'https://example.com/poster.jpg',
        description: 'Space and time.',
        meta: {'Year': '2014', 'Rating': '8.7 / 10'},
      );

      final restored = CollectionItem.fromJson(item.toJson());

      expect(restored.id, item.id);
      expect(restored.type, CollectionType.movies);
      expect(restored.title, 'Interstellar');
      expect(restored.meta['Rating'], '8.7 / 10');
      expect(restored, item, reason: 'equality is id-based');
    });
  });

  group('SavedRecord', () {
    test('survives a JSON round-trip', () {
      final record = SavedRecord(
        item: const CollectionItem(
          id: 'books:7',
          type: CollectionType.books,
          title: 'Dune',
        ),
        status: ItemStatus.saved,
        updatedAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
      );

      final restored = SavedRecord.fromJson(record.toJson());

      expect(restored.item.id, 'books:7');
      expect(restored.status, ItemStatus.saved);
      expect(restored.updatedAt, DateTime.utc(2026, 1, 2, 3, 4, 5));
    });
  });

  group('ItemStatus labels', () {
    test('vary by collection vocabulary', () {
      expect(ItemStatus.done.labelFor(CollectionType.movies), 'Watched');
      expect(ItemStatus.done.labelFor(CollectionType.books), 'Read');
      expect(ItemStatus.done.labelFor(CollectionType.cities), 'Visited');
      expect(ItemStatus.saved.labelFor(CollectionType.books), 'To read');
    });
  });
}
