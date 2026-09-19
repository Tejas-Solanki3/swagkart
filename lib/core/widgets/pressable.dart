// =============================================================================
// File: lib/core/widgets/pressable.dart
// Purpose: Tactile touch feedback wrapper widget that subtly scales down (bounces)
//          when pressed, providing responsive physical feedback for tappable elements.
// =============================================================================

import 'package:flutter/material.dart';

/// Scales down while pressed — the tactile base for every tappable surface.
///
/// Uses [AnimatedScale] driven by [GestureDetector] callbacks to achieve a
/// bouncy, physical response with no jarring splash ripples.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onTapDown,
    this.scale = 0.955,
    this.duration = const Duration(milliseconds: 130),
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onTapDown;
  final double scale;
  final Duration duration;

  @override
  State<Pressable> createState() => _PressableState();
}


class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _down() {
    widget.onTapDown?.call();
    setState(() => _pressed = true);
  }

  void _up() {
    if (mounted) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => _down(),
      onTapUp: widget.onTap == null ? null : (_) => _up(),
      onTapCancel: widget.onTap == null ? null : _up,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
