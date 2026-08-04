import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/collections.dart';
import '../discover/discover_page.dart';
import '../library/library_page.dart';

/// Top-level scaffold: a Discover tab (swipe through a catalog) and a Library
/// tab (everything you've saved or completed). The chosen collection is shared
/// across both tabs.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;
  CollectionType _type = CollectionType.movies;

  void _selectType(CollectionType type) => setState(() => _type = type);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DiscoverPage(type: _type, onTypeChanged: _selectType),
          LibraryPage(type: _type, onTypeChanged: _selectType),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
