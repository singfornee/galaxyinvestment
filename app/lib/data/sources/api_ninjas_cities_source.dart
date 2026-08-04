import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../core/collections.dart';
import '../models/collection_item.dart';
import 'item_source.dart';

/// Major world cities from API Ninjas, ordered by population.
///
/// Requires `--dart-define=API_NINJAS_KEY=...`. The endpoint has no imagery,
/// so city cards render as a coloured placeholder with the name.
class ApiNinjasCitiesSource implements ItemSource {
  ApiNinjasCitiesSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  // The endpoint caps at 30 results per call; walk the population ladder down
  // across pages so later pages surface progressively smaller cities.
  static const List<int> _minPopulationByPage = [
    9000000,
    5000000,
    3000000,
    1500000,
    800000,
  ];

  @override
  bool get isAvailable => ApiConfig.hasApiNinjas;

  @override
  Future<List<CollectionItem>> fetch({int page = 1}) async {
    final minPop =
        _minPopulationByPage[(page - 1) % _minPopulationByPage.length];

    final uri = Uri.https('api.api-ninjas.com', '/v1/city', {
      'min_population': '$minPop',
      'limit': '30',
    });

    final res = await _client.get(uri, headers: {
      'X-Api-Key': ApiConfig.apiNinjasKey,
    });
    if (res.statusCode != 200) {
      throw Exception('API Ninjas error ${res.statusCode}');
    }

    final list = (jsonDecode(res.body) as List<dynamic>);
    return list.map((raw) {
      final m = raw as Map<String, dynamic>;
      final name = m['name'] as String? ?? 'Unknown';
      final country = m['country'] as String? ?? '';
      final pop = (m['population'] as num?)?.round();
      return CollectionItem(
        id: 'cities:${name}_$country',
        type: CollectionType.cities,
        title: name,
        subtitle: country,
        imageUrl: null,
        description: pop == null
            ? ''
            : 'Home to roughly ${_humanize(pop)} people.',
        meta: {
          if (country.isNotEmpty) 'Country': country,
          if (pop != null) 'Population': _humanize(pop),
        },
      );
    }).toList();
  }

  static String _humanize(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return '$n';
  }
}
