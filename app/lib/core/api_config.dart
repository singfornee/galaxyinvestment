/// API keys, supplied at build time via `--dart-define`.
///
/// Nothing here is required to run the app: every data source degrades
/// gracefully to bundled seed data when its key is missing or a request
/// fails. Add keys to unlock live, up-to-date catalogs.
///
/// Example:
///   flutter run \
///     --dart-define=TMDB_API_KEY=xxxx \
///     --dart-define=OPENTRIPMAP_API_KEY=yyyy \
///     --dart-define=API_NINJAS_KEY=zzzz
///
/// Google Books needs no key for basic search, so it works out of the box.
class ApiConfig {
  const ApiConfig._();

  /// https://www.themoviedb.org/settings/api  (v3 API key)
  static const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');

  /// https://opentripmap.io/product  (free tier)
  static const String openTripMapApiKey =
      String.fromEnvironment('OPENTRIPMAP_API_KEY');

  /// https://api-ninjas.com/  (free tier, used for the Cities catalog)
  static const String apiNinjasKey = String.fromEnvironment('API_NINJAS_KEY');

  /// Optional: raises Google Books rate limits.
  static const String googleBooksApiKey =
      String.fromEnvironment('GOOGLE_BOOKS_API_KEY');

  static bool get hasTmdb => tmdbApiKey.isNotEmpty;
  static bool get hasOpenTripMap => openTripMapApiKey.isNotEmpty;
  static bool get hasApiNinjas => apiNinjasKey.isNotEmpty;
}
