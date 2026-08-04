import '../../core/collections.dart';

/// What the user decided about an item.
///
/// [done] is the "completed" state whose label varies by collection
/// (watched / read / visited); see [CollectionConfig.doneLabel].
enum ItemStatus {
  saved,
  done,
  skipped;

  String labelFor(CollectionType type) {
    final config = CollectionConfig.of(type);
    switch (this) {
      case ItemStatus.saved:
        return config.savedLabel;
      case ItemStatus.done:
        return config.doneLabel;
      case ItemStatus.skipped:
        return 'Skipped';
    }
  }
}
