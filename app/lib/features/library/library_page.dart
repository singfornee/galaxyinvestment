import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/collections.dart';
import '../../data/models/item_status.dart';
import '../../data/models/saved_record.dart';
import '../../state/providers.dart';
import '../../widgets/collection_selector.dart';
import '../../widgets/item_image.dart';
import '../detail/detail_sheet.dart';

/// Library tab: everything the user has decided on, filtered by collection and
/// by status (saved / done / skipped).
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({
    super.key,
    required this.type,
    required this.onTypeChanged,
  });

  final CollectionType type;
  final ValueChanged<CollectionType> onTypeChanged;

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  ItemStatus _status = ItemStatus.saved;

  @override
  Widget build(BuildContext context) {
    final config = CollectionConfig.of(widget.type);
    final library = ref.watch(libraryControllerProvider);

    final records = library.values
        .where((r) => r.item.type == widget.type && r.status == _status)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Library',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          CollectionSelector(
            selected: widget.type,
            onSelected: widget.onTypeChanged,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ItemStatus>(
              segments: [
                ButtonSegment(
                  value: ItemStatus.saved,
                  label: Text(config.savedLabel),
                ),
                ButtonSegment(
                  value: ItemStatus.done,
                  label: Text(config.doneLabel),
                ),
                const ButtonSegment(
                  value: ItemStatus.skipped,
                  label: Text('Skipped'),
                ),
              ],
              selected: {_status},
              onSelectionChanged: (s) => setState(() => _status = s.first),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: records.isEmpty
                ? _EmptyState(status: _status, type: widget.type)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) => _LibraryTile(
                      record: records[i],
                      currentStatus: _status,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LibraryTile extends ConsumerWidget {
  const _LibraryTile({required this.record, required this.currentStatus});

  final SavedRecord record;
  final ItemStatus currentStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = record.item;
    final controller = ref.read(libraryControllerProvider.notifier);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 48,
          height: 64,
          child: ItemImage(
            type: item.type,
            title: item.title,
            imageUrl: item.imageUrl,
          ),
        ),
      ),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: item.subtitle.isEmpty
          ? null
          : Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () => DetailSheet.show(context, item),
      trailing: PopupMenuButton<_TileAction>(
        onSelected: (action) {
          switch (action) {
            case _TileAction.moveSaved:
              controller.decide(item, ItemStatus.saved);
            case _TileAction.moveDone:
              controller.decide(item, ItemStatus.done);
            case _TileAction.moveSkipped:
              controller.decide(item, ItemStatus.skipped);
            case _TileAction.remove:
              controller.remove(item.id);
          }
        },
        itemBuilder: (context) {
          final config = CollectionConfig.of(item.type);
          return [
            if (currentStatus != ItemStatus.saved)
              PopupMenuItem(
                value: _TileAction.moveSaved,
                child: Text('Move to ${config.savedLabel}'),
              ),
            if (currentStatus != ItemStatus.done)
              PopupMenuItem(
                value: _TileAction.moveDone,
                child: Text('Mark as ${config.doneLabel}'),
              ),
            if (currentStatus != ItemStatus.skipped)
              const PopupMenuItem(
                value: _TileAction.moveSkipped,
                child: Text('Skip'),
              ),
            const PopupMenuItem(
              value: _TileAction.remove,
              child: Text('Remove'),
            ),
          ];
        },
      ),
    );
  }
}

enum _TileAction { moveSaved, moveDone, moveSkipped, remove }

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.status, required this.type});

  final ItemStatus status;
  final CollectionType type;

  @override
  Widget build(BuildContext context) {
    final config = CollectionConfig.of(type);
    final label = status.labelFor(type).toLowerCase();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, size: 64, color: config.color),
            const SizedBox(height: 16),
            Text(
              'Nothing in $label yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Head to Discover and swipe through ${config.plural.toLowerCase()} '
              'to build this list.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
