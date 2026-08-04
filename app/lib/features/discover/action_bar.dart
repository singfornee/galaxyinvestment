import 'package:flutter/material.dart';

import '../../core/collections.dart';

/// The three decision buttons under the deck. Mirrors the swipe gestures:
/// left = skip, up = done, right = save.
class ActionBar extends StatelessWidget {
  const ActionBar({
    super.key,
    required this.type,
    required this.onSkip,
    required this.onSave,
    required this.onDone,
  });

  final CollectionType type;
  final VoidCallback onSkip;
  final VoidCallback onSave;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final config = CollectionConfig.of(type);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.close,
          label: 'Skip',
          color: Colors.redAccent,
          onTap: onSkip,
        ),
        _ActionButton(
          icon: Icons.check,
          label: config.doneLabel,
          color: Colors.green,
          onTap: onDone,
          big: true,
        ),
        _ActionButton(
          icon: Icons.bookmark_add,
          label: config.savedLabel,
          color: config.color,
          onTap: onSave,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.big = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final size = big ? 68.0 : 56.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color.withValues(alpha: 0.12),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: color, size: big ? 34 : 28),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
