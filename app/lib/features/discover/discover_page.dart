import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/collections.dart';
import '../../state/providers.dart';
import '../../widgets/collection_selector.dart';
import 'discover_deck.dart';

/// Discover tab: pick a collection, then swipe through its deck.
class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({
    super.key,
    required this.type,
    required this.onTypeChanged,
  });

  final CollectionType type;
  final ValueChanged<CollectionType> onTypeChanged;

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  int _nonce = 0;

  void _refresh() {
    ref.invalidate(catalogProvider(widget.type));
    setState(() => _nonce++);
  }

  @override
  Widget build(BuildContext context) {
    final config = CollectionConfig.of(widget.type);
    final catalog = ref.watch(catalogProvider(widget.type));
    final isLive = ref.watch(catalogRepositoryProvider).isLive(widget.type);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Discover',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(width: 8),
                          _SourceBadge(isLive: isLive),
                        ],
                      ),
                      Text(
                        config.tagline,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reload deck',
                ),
              ],
            ),
          ),
          CollectionSelector(
            selected: widget.type,
            onSelected: widget.onTypeChanged,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: catalog.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(onRetry: _refresh, message: '$e'),
              data: (items) => DiscoverDeck(
                key: ValueKey('${widget.type.name}-$_nonce'),
                type: widget.type,
                items: items,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final color = isLive ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isLive ? 'LIVE' : 'SAMPLE',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry, required this.message});

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(
              "Couldn't load this deck",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
