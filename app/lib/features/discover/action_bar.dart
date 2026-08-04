import 'package:flutter/material.dart';

import '../../core/collections.dart';

/// The decision controls overlaid on the bottom of the card.
///
/// Skip is intentionally de-emphasised (small, muted) — the left-swipe gesture
/// is the primary way to pass. Save is the hero action; Done is secondary.
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SecondaryButton(
          icon: Icons.close_rounded,
          label: 'Skip',
          onTap: onSkip,
        ),
        const SizedBox(width: 28),
        _HeroButton(
          icon: Icons.bookmark_add_rounded,
          label: config.savedLabel,
          color: config.color,
          onTap: onSave,
        ),
        const SizedBox(width: 28),
        _SecondaryButton(
          icon: Icons.check_rounded,
          label: config.doneLabel,
          color: const Color(0xFF2E7D32),
          filled: true,
          onTap: onDone,
        ),
      ],
    );
  }
}

/// The large, primary call to action.
class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: Colors.black54,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 76,
              height: 76,
              child: Icon(icon, color: Colors.white, size: 38),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// A smaller supporting control (Skip, Done).
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Colors.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: filled ? tint : Colors.white.withValues(alpha: 0.16),
          shape: CircleBorder(
            side: filled
                ? BorderSide.none
                : BorderSide(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                icon,
                color: filled ? Colors.white : tint,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
