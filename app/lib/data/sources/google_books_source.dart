import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../core/collections.dart';
import '../models/collection_item.dart';
import 'item_source.dart';

/// Books from the Google Books API. Works with no key (a key only raises rate
/// limits), so this source is always available.
class GoogleBooksSource implements ItemSource {
  GoogleBooksSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _pageSize = 20;

  @override
  bool get isAvailable => true;

  @override
  Future<List<CollectionItem>> fetch({int page = 1}) async {
    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': 'subject:fiction',
      'orderBy': 'relevance',
      'maxResults': '$_pageSize',
      'startIndex': '${(page - 1) * _pageSize}',
      if (ApiConfig.googleBooksApiKey.isNotEmpty)
        'key': ApiConfig.googleBooksApiKey,
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Google Books error ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final items = (body['items'] as List<dynamic>? ?? []);

    return items.map((raw) {
      final m = raw as Map<String, dynamic>;
      final info = (m['volumeInfo'] as Map<String, dynamic>? ?? {});
      final authors =
          (info['authors'] as List<dynamic>?)?.cast<String>() ?? const [];
      final published = (info['publishedDate'] as String? ?? '');
      final year = published.length >= 4 ? published.substring(0, 4) : '';
      final links = (info['imageLinks'] as Map<String, dynamic>? ?? {});
      var thumb = links['thumbnail'] as String? ??
          links['smallThumbnail'] as String?;
      thumb = thumb?.replaceFirst('http://', 'https://');

      return CollectionItem(
        id: 'books:${m['id']}',
        type: CollectionType.books,
        title: info['title'] as String? ?? 'Untitled',
        subtitle: authors.isNotEmpty ? authors.first : '',
        imageUrl: thumb,
        description: info['description'] as String? ?? '',
        meta: {
          if (authors.isNotEmpty) 'Author': authors.join(', '),
          if (year.isNotEmpty) 'Published': year,
          if (info['pageCount'] != null) 'Pages': '${info['pageCount']}',
        },
      );
    }).toList();
  }
}
