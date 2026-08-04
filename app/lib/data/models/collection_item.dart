import '../../core/collections.dart';

/// A single catalog entry the user can act on — a movie, a book, a city, a
/// landmark. Immutable and source-agnostic: TMDB, Google Books and the seed
/// files all map onto this shape.
class CollectionItem {
  const CollectionItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle = '',
    this.imageUrl,
    this.description = '',
    this.meta = const {},
  });

  /// Globally unique within the app. Convention: `<type>:<sourceId>`.
  final String id;

  final CollectionType type;
  final String title;

  /// A short qualifier: release year, author, country, etc.
  final String subtitle;

  final String? imageUrl;
  final String description;

  /// Extra labelled facts shown on the detail screen (e.g. "Rating": "8.1").
  final Map<String, String> meta;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'description': description,
        'meta': meta,
      };

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      id: json['id'] as String,
      type: CollectionType.values.byName(json['type'] as String),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String? ?? '',
      meta: (json['meta'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ) ??
          const {},
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CollectionItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
