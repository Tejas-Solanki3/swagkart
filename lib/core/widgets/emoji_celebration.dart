import 'dart:async';

import 'package:flutter/material.dart';

/// A playful emoji "splash" celebration — a big 🎉 pops up in the center
/// with an elastic scale-in, a little wobble, then zooms away.
///
/// Replaces the old confetti burst for add-to-bag / order moments.
void fireCelebration(BuildContext context, {String emoji = '🎉'}) {
  final overlayState = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CelebrationPop(
      emoji: emoji,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlayState.insert(entry);
}

class _CelebrationPop extends StatefulWidget {
  const _CelebrationPop({required this.emoji, required this.onDone});

  final String emoji;
  final VoidCallback onDone;

  @override
  State<_CelebrationPop> createState() => _CelebrationPopState();
}

class _CelebrationPopState extends State<_CelebrationPop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  );

  @override
  void initState() {
    super.initState();
    _c.forward();
    // Safety net so the overlay entry can never leak.
    Timer(const Duration(milliseconds: 2400), widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Positioned.fill(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            double scale;
            double opacity;
            double rotation;
            if (t <= 0.45) {
              // Pop in with a back-overshoot.
              final k = Curves.easeOutBack.transform(t / 0.45);
              final ok = Curves.easeOutCubic.transform(t / 0.45);
              scale = 0.2 + 0.9 * k;
              opacity = ok;
              rotation = -0.22 * (1 - ok);
            } else if (t <= 0.75) {
              // Hold with a tiny wobble.
              scale = 1.1;
              opacity = 1;
              rotation = 0.07 * ((t - 0.45) / 0.3);
            } else {
              // Zoom out and fade.
              final k = Curves.easeIn.transform((t - 0.75) / 0.25);
              scale = 1.1 + 0.35 * k;
              opacity = 1 - k;
              rotation = 0.07 - 0.2 * k;
            }
            return Center(
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 112),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
