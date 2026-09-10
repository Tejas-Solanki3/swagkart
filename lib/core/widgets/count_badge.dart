import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Small animated count bubble (cart / wishlist).
class CountBadge extends StatelessWidget {
  const CountBadge({
    super.key,
    required this.count,
    this.max = 99,
  });

  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final label = count > max ? '$max+' : '$count';
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.elasticOut);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.4, end: 1).animate(curved),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey(label),
        constraints: const BoxConstraints(minWidth: 20),
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: SwagColors.accent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SwagColors.surface, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}
