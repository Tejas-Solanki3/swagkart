// =============================================================================
// File: lib/features/payment/order_placed_screen.dart
// Purpose: Post-checkout success screen rendering celebratory animations,
//          order summary breakdown, delivery timeline, and return navigation.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/emoji_celebration.dart';
import '../../core/widgets/swag_button.dart';
import '../../core/widgets/swag_icon.dart';
import '../../core/widgets/swag_logo.dart';
import '../../data/models/order.dart';
import '../../state/app_store.dart';

/// Post-checkout success screen.
///
/// Features:
/// - Fires vector checkmark celebration animation on display
/// - Displays order ID, date, payment method, delivery address, and total
/// - Provides action to return to storefront home tab
class OrderPlacedScreen extends StatefulWidget {
  const OrderPlacedScreen({super.key, required this.order});


  final SwagOrder order;

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        fireCelebration(context, asset: 'assets/icons/celebrate-check.svg');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final store = context.read<SwagAppStore>();
    return Scaffold(
      backgroundColor: SwagColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: SwagLogo(size: 34, showText: true),
            ),
            const SizedBox(height: 14),
            Container(
              width: 104,
              height: 104,
              decoration: const BoxDecoration(
                color: SwagColors.mintSoft,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SwagIcon('check', size: 46, color: SwagColors.mintDeep),
              ),
            ).animate().scale(
              begin: const Offset(0.3, 0.3),
              end: const Offset(1, 1),
              duration: 650.ms,
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 26),
            Text(
                  'Order placed!',
                  textAlign: TextAlign.center,
                  style: SwagTheme.display(size: 28),
                )
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .moveY(begin: 12, end: 0, duration: 400.ms),
            const SizedBox(height: 6),
            Text(
              'Order #${order.id} · ${order.methodLabel} · ${order.detail}',
              textAlign: TextAlign.center,
              style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Thanks, swagstar — we are packing it with care.',
              textAlign: TextAlign.center,
              style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
            ).animate(delay: 380.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 26),
            Container(
                  decoration: SwagTheme.cardDecoration(),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _Row(
                        label: 'Items',
                        value: order.items
                            .map((i) => '${i.product.name} ×${i.qty}')
                            .take(3)
                            .join(' · '),
                      ),
                      const SizedBox(height: 12),
                      _Row(label: 'Subtotal', value: inr(order.subtotal)),
                      if (order.discount > 0) ...[
                        const SizedBox(height: 8),
                        _Row(
                          label: 'Discount',
                          value: '− ${inr(order.discount)}',
                          valueColor: SwagColors.mintDeep,
                        ),
                      ],
                      const SizedBox(height: 8),
                      _Row(
                        label: 'Shipping',
                        value: order.shipping <= 0
                            ? 'Free'
                            : inr(order.shipping),
                        valueColor: order.shipping <= 0
                            ? SwagColors.mintDeep
                            : null,
                      ),
                      const Divider(height: 24, color: SwagColors.line),
                      _Row(label: 'Paid', value: inr(order.total), bold: true),
                    ],
                  ),
                )
                .animate(delay: 450.ms)
                .fadeIn(duration: 400.ms)
                .moveY(begin: 16, end: 0, duration: 400.ms),
            const SizedBox(height: 16),
            Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: SwagColors.butterSoft,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: SwagColors.butter.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SwagColors.butter.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: SwagColors.butter,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🪙', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.lastEarnedPoints > 0
                                  ? '+${store.lastEarnedPoints} SwagPoints Earned!'
                                  : '+${(order.total * 0.10).round()} SwagPoints Earned!',
                              style: SwagTheme.display(
                                size: 16,
                                weight: FontWeight.w800,
                                color: SwagColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your updated balance: ${store.swagPoints} pts. Use them on any drop!',
                              style: SwagTheme.body(
                                size: 12,
                                color: SwagColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: 500.ms)
                .fadeIn(duration: 400.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                ),
            const SizedBox(height: 22),
            SwagButton(
              label: 'Track order',
              icon: 'package',
              background: SwagColors.surface,
              foreground: SwagColors.ink,
              onTap: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Live tracking lands in the next phase'),
                    ),
                  );
              },
            ).animate(delay: 550.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 12),
            SwagButton(
              label: 'Back to home',
              icon: 'home',
              onTap: () {
                store.requestTab(0);
                SwagNav.popToRoot(context);
              },
            ).animate(delay: 650.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: SwagTheme.body(
            size: 13,
            color: valueColor ?? SwagColors.inkSoft,
            weight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: SwagTheme.body(
              size: 13,
              color: valueColor ?? SwagColors.ink,
              weight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
