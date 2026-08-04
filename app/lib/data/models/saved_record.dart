import 'collection_item.dart';
import 'item_status.dart';

/// A user decision persisted to local storage: the item, its status, and when
/// it was last touched. Stored as plain JSON in Hive (no code generation), so
/// the whole item travels with the record and the library works offline.
class SavedRecord {
  const SavedRecord({
    required this.item,
    required this.status,
    required this.updatedAt,
  });

  final CollectionItem item;
  final ItemStatus status;
  final DateTime updatedAt;

  SavedRecord copyWith({ItemStatus? status, DateTime? updatedAt}) {
    return SavedRecord(
      item: item,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
        'status': status.name,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SavedRecord.fromJson(Map<String, dynamic> json) {
    return SavedRecord(
      item: CollectionItem.fromJson(
        Map<String, dynamic>.from(json['item'] as Map),
      ),
      status: ItemStatus.values.byName(json['status'] as String),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
