import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../core/collections.dart';
import '../models/collection_item.dart';
import 'item_source.dart';

/// Popular movies from The Movie Database (TMDB).
///
/// Requires a v3 API key via `--dart-define=TMDB_API_KEY=...`.
class TmdbSource implements ItemSource {
  TmdbSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _imageBase = 'https://image.tmdb.org/t/p/w500';

  @override
  bool get isAvailable => ApiConfig.hasTmdb;

  @override
  Future<List<CollectionItem>> fetch({int page = 1}) async {
    final uri = Uri.https('api.themoviedb.org', '/3/movie/popular', {
      'api_key': ApiConfig.tmdbApiKey,
      'page': '$page',
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('TMDB error ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (body['results'] as List<dynamic>? ?? []);

    return results.map((raw) {
      final m = raw as Map<String, dynamic>;
      final poster = m['poster_path'] as String?;
      final release = (m['release_date'] as String? ?? '');
      final year = release.length >= 4 ? release.substring(0, 4) : '';
      final rating = (m['vote_average'] as num?)?.toStringAsFixed(1) ?? '';
      return CollectionItem(
        id: 'movies:${m['id']}',
        type: CollectionType.movies,
        title: m['title'] as String? ?? 'Untitled',
        subtitle: year,
        imageUrl: poster == null ? null : '$_imageBase$poster',
        description: m['overview'] as String? ?? '',
        meta: {
          if (year.isNotEmpty) 'Year': year,
          if (rating.isNotEmpty) 'Rating': '$rating / 10',
        },
      );
    }).toList();
  }
}
