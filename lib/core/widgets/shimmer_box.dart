import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Soft sweeping shimmer used for skeleton loading states.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.radius,
    this.color = SwagColors.sandSoft,
  });

  final double radius;
  final Color color;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                (t - 0.45).clamp(0.0, 1.0),
                t.clamp(0.0, 1.0),
                (t + 0.45).clamp(0.0, 1.0),
              ],
              colors: [
                widget.color,
                Colors.white.withValues(alpha: 0.75),
                widget.color,
              ],
            ),
          ),
        );
      },
    );
  }
}
