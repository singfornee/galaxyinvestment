import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../core/collections.dart';
import '../models/collection_item.dart';
import 'item_source.dart';

/// Notable attractions from OpenTripMap, sampled around a rotating set of
/// world cities so the deck varies page to page.
///
/// Requires `--dart-define=OPENTRIPMAP_API_KEY=...`. The radius endpoint
/// returns names and categories but not photos, so cards fall back to a
/// coloured placeholder for image-less results.
class OpenTripMapSource implements ItemSource {
  OpenTripMapSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // (name, lon, lat) anchors for popular destinations.
  static const List<List<Object>> _anchors = [
    ['Paris', 2.3522, 48.8566],
    ['Rome', 12.4964, 41.9028],
    ['Tokyo', 139.6917, 35.6895],
    ['New York', -74.0060, 40.7128],
    ['Istanbul', 28.9784, 41.0082],
    ['Barcelona', 2.1734, 41.3851],
  ];

  @override
  bool get isAvailable => ApiConfig.hasOpenTripMap;

  @override
  Future<List<CollectionItem>> fetch({int page = 1}) async {
    final anchor = _anchors[(page - 1) % _anchors.length];
    final city = anchor[0] as String;
    final lon = anchor[1] as double;
    final lat = anchor[2] as double;

    final uri = Uri.https('api.opentripmap.com', '/0.1/en/places/radius', {
      'radius': '20000',
      'lon': '$lon',
      'lat': '$lat',
      'kinds': 'cultural,architecture,historic',
      'rate': '3',
      'format': 'json',
      'limit': '30',
      'apikey': ApiConfig.openTripMapApiKey,
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('OpenTripMap error ${res.statusCode}');
    }

    final list = (jsonDecode(res.body) as List<dynamic>);
    return list
        .map((e) => e as Map<String, dynamic>)
        .where((m) => (m['name'] as String? ?? '').trim().isNotEmpty)
        .map((m) {
      final kinds = (m['kinds'] as String? ?? '')
          .split(',')
          .map((k) => k.replaceAll('_', ' ').trim())
          .where((k) => k.isNotEmpty)
          .take(3)
          .join(', ');
      return CollectionItem(
        id: 'attractions:${m['xid']}',
        type: CollectionType.attractions,
        title: m['name'] as String,
        subtitle: city,
        imageUrl: null,
        description: kinds.isEmpty ? '' : 'Categories: $kinds.',
        meta: {
          'Near': city,
          if (kinds.isNotEmpty) 'Type': kinds,
        },
      );
    }).toList();
  }
}
