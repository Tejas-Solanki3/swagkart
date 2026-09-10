import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/emoji_celebration.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swag_button.dart';
import '../../core/widgets/swag_icon.dart';
import '../../data/demo_data.dart';
import '../../data/models/cart_item.dart';
import '../../state/app_store.dart';
import '../payment/payment_screen.dart';

class BagScreen extends StatefulWidget {
  const BagScreen({super.key});

  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  final TextEditingController _promoController = TextEditingController();
  String? _promoError;
  bool _promoStamp = false;
  List<CartItem> _lastCleared = const [];
  Timer? _undoTimer;

  @override
  void dispose() {
    _promoController.dispose();
    _undoTimer?.cancel();
    super.dispose();
  }

  void _applyPromo(SwagAppStore store, {String? code}) {
    if (code != null) {
      _promoController.text = code;
    }
    final ok = store.applyPromo(_promoController.text);
    setState(() {
      _promoStamp = ok;
      _promoError = ok ? null : 'Hmm, that code isn’t valid. Try SWAG15.';
    });
    if (ok) {
      final pct = store.appliedPromo!.pct.round();
      fireCelebration(context, asset: 'assets/icons/celebrate-pop.svg');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${store.appliedPromo!.code} applied — flat $pct% off!',
              style: SwagTheme.body(
                size: 13,
                weight: FontWeight.w700,
                color: SwagColors.canvas,
              ),
            ),
          ),
        );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = swagPad(MediaQuery.sizeOf(context).width);
    return Consumer<SwagAppStore>(
      builder: (context, store, _) {
        if (store.cart.isEmpty) {
          return EmptyState(
            image: 'assets/images/empty-bag.svg',
            title: 'Your bag is feeling light',
            subtitle: 'Nothing in here yet. Go find something worth bragging about.',
            actionLabel: _lastCleared.isNotEmpty ? 'Undo clear' : 'Start shopping',
            onAction: () {
              if (_lastCleared.isNotEmpty) {
                store.restoreCart(_lastCleared);
                _undoTimer?.cancel();
                setState(() => _lastCleared = const []);
              } else {
                store.requestTab(0);
              }
            },
          );
        }
        return ListView(
          padding: EdgeInsets.fromLTRB(pad, 14, pad, 130),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Your Bag',
                    style: SwagTheme.display(size: 26),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: SwagColors.surfaceMist,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${store.cartCount} item${store.cartCount == 1 ? '' : 's'}',
                    style: SwagTheme.body(
                      size: 12,
                      weight: FontWeight.w800,
                      color: SwagColors.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              if (store.cart.isNotEmpty)
                Pressable(
                  onTap: () {
                    _undoTimer?.cancel();
                    setState(() => _lastCleared = List.of(store.cart));
                    store.clearCart();
                    fireCelebration(context);
                    // Undo lives on the empty state for 8s, then expires.
                    _undoTimer = Timer(const Duration(seconds: 8), () {
                      if (mounted) setState(() => _lastCleared = const []);
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SwagIcon('trash', size: 15, color: SwagColors.inkSoft),
                      const SizedBox(width: 5),
                      Text(
                        'Clear',
                        style: SwagTheme.body(size: 12, weight: FontWeight.w700, color: SwagColors.inkSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (store.qualifiesFreeShipping)
              _FreeShipBanner(amount: store.afterDiscount)
            else
              _FreeShipProgress(current: store.afterDiscount, threshold: 999),
            const SizedBox(height: 14),
            for (final item in store.cart)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CartItemCard(item: item, store: store),
              ),
            const SizedBox(height: 6),
            _PromoCard(
              controller: _promoController,
              error: _promoError,
              applied: store.appliedPromo,
              stamped: _promoStamp,
              onApply: () => _applyPromo(store),
              onQuickApply: (code) => _applyPromo(store, code: code),
              onClear: () {
                store.clearPromo();
                setState(() {
                  _promoStamp = false;
                  _promoError = null;
                  _promoController.clear();
                });
              },
            ),
            const SizedBox(height: 14),
            _SummaryCard(store: store),
            const SizedBox(height: 16),
            SwagButton(
              label: 'Proceed to Payment',
              icon: 'lock',
              trailingIcon: 'arrow-right',
              shine: true,
              height: 58,
              onTap: () => SwagNav.push(context, (_) => const PaymentScreen()),
            ),
            const SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SwagIcon('lock', size: 12, color: SwagColors.inkFaint),
                  const SizedBox(width: 5),
                  Text(
                    '256-bit encrypted · GST invoice included',
                    style: SwagTheme.body(size: 11.5, color: SwagColors.inkFaint),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FreeShipBanner extends StatelessWidget {
  const _FreeShipBanner({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SwagColors.successSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SwagColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const SwagIcon('truck', size: 20, color: SwagColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Free express delivery unlocked on this order!',
              style: SwagTheme.body(size: 12.5, weight: FontWeight.w800, color: SwagColors.success),
            ),
          ),
          const SwagIcon('check', size: 18, color: SwagColors.success),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).moveY(begin: 12, end: 0, duration: 300.ms);
  }
}

class _FreeShipProgress extends StatelessWidget {
  const _FreeShipProgress({required this.current, required this.threshold});

  final double current;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    final t = (current / threshold).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SwagColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SwagColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SwagIcon('truck', size: 18, color: SwagColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Add ',
                        style: TextStyle(fontSize: 12.5, color: SwagColors.inkSoft),
                      ),
                      TextSpan(
                        text: inr(threshold - current),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: SwagColors.ink,
                        ),
                      ),
                      const TextSpan(
                        text: ' more for FREE express delivery',
                        style: TextStyle(fontSize: 12.5, color: SwagColors.inkSoft),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: SwagColors.surfaceMist),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: t,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: t),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return FractionallySizedBox(
                          widthFactor: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [SwagColors.mint, SwagColors.mist],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item, required this.store});

  final CartItem item;
  final SwagAppStore store;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: SwagColors.blushSoft,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const SwagIcon('trash', size: 22, color: SwagColors.danger),
      ),
      onDismissed: (_) => store.removeItem(item),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: SwagColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: SwagColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: SwagColors.photoMat,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(item.product.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.brand.toUpperCase(),
                    style: SwagTheme.body(
                      size: 9.5,
                      weight: FontWeight.w700,
                      color: SwagColors.inkFaint,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.product.name,
                    style: SwagTheme.display(size: 14.5, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Size ${item.size} · ${item.color}',
                    style: SwagTheme.body(size: 11, color: SwagColors.inkSoft),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        inr(item.lineTotal),
                        style: SwagTheme.display(size: 15, weight: FontWeight.w800),
                      ),
                      const Spacer(),
                      _MiniStepper(
                        qty: item.qty,
                        onChanged: (q) => store.setQty(item, q),
                      ),
                    ],
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

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({required this.qty, required this.onChanged});

  final int qty;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: SwagColors.canvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwagColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Step(icon: 'minus', disabled: qty <= 1, onTap: () => onChanged(qty - 1)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: SizedBox(
              width: 28,
              key: ValueKey(qty),
              child: Center(
                child: Text(
                  '$qty',
                  style: SwagTheme.body(size: 13, weight: FontWeight.w800),
                ),
              ),
            ),
          ),
          _Step(icon: 'plus', onTap: () => onChanged(qty + 1)),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.onTap, this.disabled = false});

  final String icon;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: disabled ? SwagColors.surfaceMist : SwagColors.surface,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SwagIcon(
            icon,
            size: 14,
            color: disabled ? SwagColors.inkFaint : SwagColors.ink,
          ),
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.controller,
    required this.error,
    required this.applied,
    required this.stamped,
    required this.onApply,
    required this.onQuickApply,
    required this.onClear,
  });

  final TextEditingController controller;
  final String? error;
  final SwagAppStorePromoRef? applied;
  final bool stamped;
  final VoidCallback onApply;
  final void Function(String code) onQuickApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasCode = applied != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SwagColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasCode ? SwagColors.success.withValues(alpha: 0.5) : SwagColors.line,
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SwagIcon('tag', size: 18, color: SwagColors.accent),
              const SizedBox(width: 8),
              Text(
                'Promo code',
                style: SwagTheme.body(size: 14, weight: FontWeight.w800),
              ),
              if (hasCode) ...[
                const Spacer(),
                Pressable(
                  onTap: onClear,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SwagIcon('close', size: 14, color: SwagColors.inkSoft),
                      const SizedBox(width: 4),
                      Text(
                        'Remove',
                        style: SwagTheme.body(size: 11, weight: FontWeight.w700, color: SwagColors.inkSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (hasCode)
            AnimatedBuilder(
              animation: const AlwaysStoppedAnimation(0),
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset.zero,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: SwagColors.successSoft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: SwagColors.success,
                        width: 1.4,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SwagIcon('check', size: 18, color: SwagColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${applied!.code} applied — flat ${applied!.pct.round()}% off',
                            style: SwagTheme.body(
                              size: 13,
                              weight: FontWeight.w800,
                              color: SwagColors.success,
                            ),
                          ),
                        ),
                        Text(
                          'VERIFIED',
                          style: SwagTheme.body(
                            size: 9,
                            weight: FontWeight.w800,
                            color: SwagColors.success.withValues(alpha: 0.6),
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
              .animate(
                delay: stamped ? 0.ms : 200.ms,
              ).scale(begin: const Offset(1.6, 1.6), end: const Offset(1, 1), duration: 420.ms, curve: Curves.easeOutBack).rotate(begin: 0.06, end: 0, duration: 420.ms)
          else
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: SwagColors.canvas,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: error != null ? SwagColors.danger : SwagColors.line,
                        width: 1.4,
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => onApply(),
                      style: SwagTheme.body(
                        size: 13,
                        weight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14),
                        hintText: 'Try SWAG15',
                        hintStyle: TextStyle(
                          color: SwagColors.inkFaint,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 92,
                  height: 46,
                  child: SwagButton(
                    label: 'Apply',
                    expanded: true,
                    height: 46,
                    fontSize: 14,
                    onTap: onApply,
                  ),
                ),
              ],
            ),
          if (!hasCode) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'One tap:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SwagColors.inkFaint),
                ),
                const SizedBox(width: 8),
                _CodeChip(code: 'SWAG15', note: '15% off', onTap: onQuickApply),
                const SizedBox(width: 8),
                _CodeChip(code: 'SWAG10', note: '10% off', onTap: onQuickApply),
              ],
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const SwagIcon('bolt', size: 13, color: SwagColors.danger),
                const SizedBox(width: 5),
                Text(
                  error!,
                  style: SwagTheme.body(size: 11.5, weight: FontWeight.w600, color: SwagColors.danger),
                ),
              ],
            ).animate().moveX(begin: -8, end: 0, duration: 300.ms),
          ],
        ],
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  const _CodeChip({required this.code, required this.note, required this.onTap});

  final String code;
  final String note;
  final void Function(String code) onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => onTap(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: SwagColors.canvas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SwagColors.line, width: 1.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: SwagTheme.body(
                size: 11.5,
                weight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              note,
              style: SwagTheme.body(size: 10, color: SwagColors.inkFaint),
            ),
          ],
        ),
      ),
    );
  }
}

/// Type alias so the promo card doesn't import demo_data directly.
typedef SwagAppStorePromoRef = Promo;

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.store});

  final SwagAppStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwagColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SwagColors.line),
        boxShadow: [
          BoxShadow(
            color: SwagColors.ink.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _row('Subtotal (${store.cartCount} items)', inr(store.subtotal)),
          if (store.appliedPromo != null) ...[
            const SizedBox(height: 8),
            _row(
              'Promo ${store.appliedPromo!.code}',
              '-${inr(store.discountAmount)}',
              valueColor: SwagColors.success,
            ),
          ],
          const SizedBox(height: 8),
          _row(
            'Shipping',
            store.shippingFee == 0 ? 'FREE' : inr(store.shippingFee),
            valueColor: store.shippingFee == 0 ? SwagColors.success : null,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: SwagColors.line),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Total',
                style: SwagTheme.display(size: 17, weight: FontWeight.w800),
              ),
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: store.total),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, _) => Text(
                  inr(value),
                  style: SwagTheme.display(size: 24, weight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Inclusive of all duties & taxes (GST)',
            style: SwagTheme.body(size: 11, color: SwagColors.inkFaint),
          ),
          if (store.savings > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: SwagColors.butterSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SwagIcon('gift', size: 16, color: SwagColors.accentDeep),
                  const SizedBox(width: 7),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: store.savings),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, _) => Text(
                      'You’re saving ${inr(value)} on this order',
                      style: SwagTheme.body(
                        size: 12,
                        weight: FontWeight.w800,
                        color: SwagColors.accentDeep,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(
          label,
          style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
        ),
        const Spacer(),
        Text(
          value,
          style: SwagTheme.body(
            size: 13.5,
            weight: FontWeight.w800,
            color: valueColor ?? SwagColors.ink,
          ),
        ),
      ],
    );
  }
}
