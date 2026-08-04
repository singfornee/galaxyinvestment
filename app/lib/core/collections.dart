import 'package:flutter/material.dart';

/// The kinds of things Curio can collect.
///
/// Adding a new collection is deliberately a one-stop change: define it here,
/// add a data source in `data/sources/`, and wire it in `CatalogRepository`.
enum CollectionType { attractions, cities, movies, books }

/// Static, per-collection presentation and vocabulary.
///
/// The three swipe actions are universal (skip / save / done) but each
/// collection speaks about them differently: a movie is *watched*, a book is
/// *read*, a place is *visited*.
class CollectionConfig {
  const CollectionConfig({
    required this.type,
    required this.label,
    required this.plural,
    required this.icon,
    required this.color,
    required this.savedLabel,
    required this.doneLabel,
    required this.tagline,
  });

  final CollectionType type;

  /// Singular human label, e.g. "Movie".
  final String label;

  /// Plural human label, e.g. "Movies".
  final String plural;

  final IconData icon;
  final Color color;

  /// Label for the "save for later" bucket, e.g. "Watchlist", "To read".
  final String savedLabel;

  /// Label for the "completed" bucket, e.g. "Watched", "Read", "Visited".
  final String doneLabel;

  final String tagline;

  static const Map<CollectionType, CollectionConfig> _all = {
    CollectionType.attractions: CollectionConfig(
      type: CollectionType.attractions,
      label: 'Attraction',
      plural: 'Attractions',
      icon: Icons.attractions_outlined,
      color: Color(0xFF2A9D8F),
      savedLabel: 'Wishlist',
      doneLabel: 'Visited',
      tagline: 'Landmarks worth the detour',
    ),
    CollectionType.cities: CollectionConfig(
      type: CollectionType.cities,
      label: 'City',
      plural: 'Cities',
      icon: Icons.location_city_outlined,
      color: Color(0xFF457B9D),
      savedLabel: 'Wishlist',
      doneLabel: 'Visited',
      tagline: 'Places to wander',
    ),
    CollectionType.movies: CollectionConfig(
      type: CollectionType.movies,
      label: 'Movie',
      plural: 'Movies',
      icon: Icons.movie_outlined,
      color: Color(0xFFE76F51),
      savedLabel: 'Watchlist',
      doneLabel: 'Watched',
      tagline: 'Your next watch',
    ),
    CollectionType.books: CollectionConfig(
      type: CollectionType.books,
      label: 'Book',
      plural: 'Books',
      icon: Icons.menu_book_outlined,
      color: Color(0xFFE9C46A),
      savedLabel: 'To read',
      doneLabel: 'Read',
      tagline: 'Stories to sink into',
    ),
  };

  static CollectionConfig of(CollectionType type) => _all[type]!;

  static List<CollectionConfig> get all => CollectionType.values.map(of).toList();
}
