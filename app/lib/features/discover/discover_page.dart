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
    final catalog = ref.watch(catalogProvider(widget.type));
    final isLive = ref.watch(catalogRepositoryProvider).isLive(widget.type);

    return Stack(
      children: [
        // Full-screen deck fills everything behind the floating controls.
        Positioned.fill(
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
        // Floating top bar: collection selector + source badge + reload.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: CollectionSelector(
                      selected: widget.type,
                      onSelected: widget.onTypeChanged,
                    ),
                  ),
                  IconButton(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    color: Colors.white,
                    tooltip: 'Reload deck',
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
        // Source badge tucked just under the selector, clear of the chips.
        Positioned(
          top: 0,
          right: 12,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 56),
              child: _SourceBadge(isLive: isLive),
            ),
          ),
        ),
      ],
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
        color: color.withValues(alpha: 0.15),
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
