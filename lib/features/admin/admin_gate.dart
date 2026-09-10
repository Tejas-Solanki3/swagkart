import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swag_button.dart';
import '../../core/widgets/swag_icon.dart';

/// Phase 3 placeholder — the full admin login + dashboard lands here.
class AdminGate extends StatelessWidget {
  const AdminGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwagColors.ink,
      body: SafeArea(
        child: Stack(
          children: [
            // Faint candy dots backdrop
            Positioned.fill(
              child: CustomPaint(painter: _DotPainter()),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Pressable(
                          onTap: () => SwagNav.pop(context),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: SwagIcon('arrow-left', size: 20, color: SwagColors.canvas),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'SWAGKART MERCHANT',
                          style: SwagTheme.body(
                            size: 12,
                            weight: FontWeight.w800,
                            color: SwagColors.canvas.withValues(alpha: 0.6),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [SwagColors.accent, SwagColors.butter],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: SwagColors.accent.withValues(alpha: 0.4),
                                    blurRadius: 40,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: SwagIcon('lock', size: 40, color: SwagColors.ink),
                              ),
                            ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut).fadeIn(duration: 400.ms),
                            const SizedBox(height: 24),
                            Text(
                              'Admin console',
                              style: SwagTheme.display(size: 30, color: SwagColors.canvas),
                            ).animate(delay: 150.ms).fadeIn(duration: 400.ms).moveY(begin: 16, end: 0, duration: 400.ms),
                            const SizedBox(height: 8),
                            Text(
                              'Login, KPIs, revenue analytics, orders and category management are cooking in Phase 3.',
                              textAlign: TextAlign.center,
                              style: SwagTheme.body(
                                size: 13.5,
                                color: SwagColors.canvas.withValues(alpha: 0.7),
                              ),
                            ).animate(delay: 250.ms).fadeIn(duration: 400.ms).moveY(begin: 16, end: 0, duration: 400.ms),
                            const SizedBox(height: 26),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                for (final item in const [
                                  'Merchant login',
                                  'KPI dashboard',
                                  'Revenue analytics',
                                  'Order management',
                                  'Category control',
                                ])
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.07),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.14),
                                      ),
                                    ),
                                    child: Text(
                                      item,
                                      style: SwagTheme.body(
                                        size: 11.5,
                                        weight: FontWeight.w700,
                                        color: SwagColors.canvas.withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ),
                              ],
                            ).animate(delay: 380.ms).fadeIn(duration: 500.ms).moveY(begin: 20, end: 0, duration: 500.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                    child: SwagButton(
                      label: 'Back to the store',
                      icon: 'bag',
                      background: SwagColors.canvas,
                      foreground: SwagColors.ink,
                      height: 54,
                      onTap: () => SwagNav.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SwagColors.canvas.withValues(alpha: 0.05)
      ..strokeWidth = 2;
    const step = 34.0;
    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
