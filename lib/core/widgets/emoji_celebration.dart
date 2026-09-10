import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A celebration splash: a white screen fades in, the art pops up
/// center-stage with a soft elastic + wobble, holds for about a
/// second, then everything fades away. ~1.6s total.
///
/// Uses vector art (not emoji text) so it renders instantly on web,
/// where emoji fonts load a second late.
void fireCelebration(BuildContext context, {String? asset}) {
  final path = asset ?? 'assets/icons/celebrate-party.svg';
  final overlayState = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => IgnorePointer(
      child: _CelebrationPop(
        asset: path,
        onDone: () {
          if (entry.mounted) entry.remove();
        },
      ),
    ),
  );
  overlayState.insert(entry);
}

class _CelebrationPop extends StatefulWidget {
  const _CelebrationPop({required this.asset, required this.onDone});

  final String asset;
  final VoidCallback onDone;

  @override
  State<_CelebrationPop> createState() => _CelebrationPopState();
}

class _CelebrationPopState extends State<_CelebrationPop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
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
    // Root must be a plain (non-Positioned) widget: the overlay's stack
    // gives it full-screen size, and the ParentData contract stays intact.
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        // White backdrop: quick fade-in, held for ~1s, smooth fade-out.
        final double backdrop;
        if (t < 0.15) {
          backdrop = Curves.easeOutCubic.transform(t / 0.15);
        } else if (t < 0.78) {
          backdrop = 1.0;
        } else {
          backdrop = 1.0 - Curves.easeInCubic.transform((t - 0.78) / 0.22);
        }
        // Art: gentle pop-in, soft wobble, smooth exit.
        double scale;
        double opacity;
        double rotation;
        if (t <= 0.4) {
          final k = Curves.easeOutBack.transform(t / 0.4);
          final ok = Curves.easeOutCubic.transform(t / 0.4);
          scale = 0.35 + 0.65 * k;
          opacity = ok;
          rotation = -0.16 * (1 - ok);
        } else if (t <= 0.8) {
          final k = (t - 0.4) / 0.4;
          scale = 1.0 + 0.045 * math.sin(k * math.pi);
          opacity = 1.0;
          rotation = 0.045 * math.sin(k * 2 * math.pi);
        } else {
          final k = Curves.easeInCubic.transform((t - 0.8) / 0.2);
          scale = 1.0 + 0.28 * k;
          opacity = 1.0 - k;
          rotation = 0.0;
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Colors.white.withValues(alpha: backdrop),
            ),
            Center(
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: SvgPicture.asset(
                      widget.asset,
                      width: 170,
                      height: 170,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
