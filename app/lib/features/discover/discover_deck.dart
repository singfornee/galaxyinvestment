import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/collections.dart';
import '../../data/models/collection_item.dart';
import '../../data/models/item_status.dart';
import '../../state/providers.dart';
import '../detail/detail_sheet.dart';
import 'action_bar.dart';
import 'swipe_card.dart';

/// The interactive card stack for one collection. Captures the catalog once so
/// recording a decision (which mutates the library) never rebuilds or resets
/// the deck mid-swipe.
class DiscoverDeck extends ConsumerStatefulWidget {
  const DiscoverDeck({super.key, required this.type, required this.items});

  final CollectionType type;
  final List<CollectionItem> items;

  @override
  ConsumerState<DiscoverDeck> createState() => _DiscoverDeckState();
}

class _DiscoverDeckState extends ConsumerState<DiscoverDeck> {
  final CardSwiperController _controller = CardSwiperController();
  late List<CollectionItem> _cards;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    // Drop items the user has already decided on so the deck stays fresh.
    final library = ref.read(libraryControllerProvider);
    _cards = widget.items.where((i) => !library.containsKey(i.id)).toList();
    _finished = _cards.isEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _record(CollectionItem item, ItemStatus status) {
    ref.read(libraryControllerProvider.notifier).decide(item, status);
    final config = CollectionConfig.of(item.type);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text('${item.title} → ${status.labelFor(item.type)}'),
        backgroundColor: status == ItemStatus.skipped ? null : config.color,
      ),
    );
  }

  ItemStatus _statusFor(CardSwiperDirection direction) {
    switch (direction) {
      case CardSwiperDirection.right:
        return ItemStatus.saved;
      case CardSwiperDirection.top:
        return ItemStatus.done;
      default:
        return ItemStatus.skipped;
    }
  }

  bool _onSwipe(int previous, int? current, CardSwiperDirection direction) {
    if (previous < 0 || previous >= _cards.length) return true;
    _record(_cards[previous], _statusFor(direction));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _CaughtUp(type: widget.type);
    }

    final displayed = math.min(3, _cards.length);
    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            controller: _controller,
            cardsCount: _cards.length,
            numberOfCardsDisplayed: displayed,
            isLoop: false,
            backCardOffset: const Offset(0, 32),
            padding: const EdgeInsets.all(16),
            allowedSwipeDirection: const AllowedSwipeDirection.only(
              left: true,
              right: true,
              up: true,
            ),
            onSwipe: _onSwipe,
            onEnd: () => setState(() => _finished = true),
            cardBuilder: (context, index, _, __) {
              final item = _cards[index];
              return SwipeCard(
                item: item,
                onInfo: () => DetailSheet.show(context, item),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: ActionBar(
            type: widget.type,
            onSkip: () => _controller.swipe(CardSwiperDirection.left),
            onSave: () => _controller.swipe(CardSwiperDirection.right),
            onDone: () => _controller.swipe(CardSwiperDirection.top),
          ),
        ),
      ],
    );
  }
}

class _CaughtUp extends StatelessWidget {
  const _CaughtUp({required this.type});

  final CollectionType type;

  @override
  Widget build(BuildContext context) {
    final config = CollectionConfig.of(type);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.done_all, size: 72, color: config.color),
            const SizedBox(height: 16),
            Text(
              "You're all caught up",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve been through every ${config.label.toLowerCase()} in this deck. '
              'Check your Library, or pull to refresh for more.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
