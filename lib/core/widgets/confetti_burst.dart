// =============================================================================
// File: lib/core/widgets/confetti_burst.dart
// Purpose: Physics-based celebratory confetti burst particle system rendered
//          via an overlay entry on order completion or promotions.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Single particle model for the confetti explosion animation.
class _ConfettiParticle {
  _ConfettiParticle(math.Random rng, List<Color> palette)
    : angle = rng.nextDouble() * math.pi * 2,
      distance = 70 + rng.nextDouble() * 130,
      size = 5 + rng.nextDouble() * 5,
      spin = (rng.nextDouble() - 0.5) * 10,
      speed = 0.75 + rng.nextDouble() * 0.5,
      color = palette[rng.nextInt(palette.length)],
      isCircle = rng.nextBool();
  final double angle;
  final double distance;
  final double size;
  final double spin;
  final double speed;
  final Color color;
  final bool isCircle;
}

/// Full-screen celebratory burst widget. Fire it using [fireConfetti].
class ConfettiBurst extends StatefulWidget {

  const ConfettiBurst({super.key, this.origin = const Offset(0.5, 0.78)});

  /// Relative (0..1) burst origin on screen.
  final Offset origin;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  )..forward();

  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    _particles = List.generate(
      30,
      (i) => _ConfettiParticle(rng, SwagColors.pastel),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final ox = size.width * widget.origin.dx;
          final oy = size.height * widget.origin.dy;
          return Stack(
            children: [for (final p in _particles) _particleAt(ox, oy, p, t)],
          );
        },
      ),
    );
  }

  Widget _particleAt(double ox, double oy, _ConfettiParticle p, double t) {
    final progress = (t / p.speed).clamp(0.0, 1.0);
    if (progress >= 1) return const SizedBox.shrink();
    final ease = 1 - math.pow(1 - progress, 2.2);
    final x = ox + math.cos(p.angle) * p.distance * ease;
    final y = oy + math.sin(p.angle) * p.distance * ease + 240 * ease * ease;
    final rotation = p.spin * progress;
    final opacity = (1 - math.pow(progress, 3.0)).toDouble();
    return Positioned(
      left: x - p.size / 2,
      top: y - p.size / 2,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: rotation,
          child: p.isCircle
              ? Container(
                  width: p.size,
                  height: p.size,
                  decoration: BoxDecoration(
                    color: p.color,
                    shape: BoxShape.circle,
                  ),
                )
              : Container(
                  width: p.size,
                  height: p.size * 1.6,
                  decoration: BoxDecoration(
                    color: p.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Inserts a temporary full-screen confetti overlay above everything.
void fireConfetti(
  BuildContext context, {
  Offset origin = const Offset(0.5, 0.78),
}) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(builder: (_) => ConfettiBurst(origin: origin));
  overlay.insert(entry);
  Future<void>.delayed(const Duration(milliseconds: 1250), () {
    if (entry.mounted) entry.remove();
  });
}
