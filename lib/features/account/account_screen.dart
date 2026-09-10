import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swag_button.dart';
import '../../core/widgets/swag_icon.dart';
import '../../state/app_store.dart';
import '../admin/admin_gate.dart';
import '../payment/order_placed_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<SwagAppStore>();
    final lastOrder = store.lastOrder;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 130),
      children: [
        Text(
          'Your Account',
          style: SwagTheme.display(size: 26),
        ),
        const SizedBox(height: 16),
        _ProfileCard(
          savedCount: store.wishlist.length,
          bagCount: store.cartCount,
        )
            .animate().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 480.ms, curve: Curves.easeOutBack).fadeIn(duration: 380.ms),
        const SizedBox(height: 18),
        _QuickActions(
          onOrders: () {
            if (store.lastOrder != null) {
              SwagNav.push(
                context,
                (_) => OrderPlacedScreen(order: store.lastOrder!),
              );
            } else {
              _toast(context, 'No orders yet — your first drop is one tap away');
            }
          },
          onWishlist: () => store.requestTab(2),
          onAddresses: () => _toast(context, 'Saved addresses land with Phase 2.'),
          onSupport: () => _toast(context, 'Support desk opens with Phase 2.'),
        )
            .animate(delay: 90.ms).fadeIn(duration: 420.ms).moveY(begin: 16, end: 0, duration: 420.ms, curve: Curves.easeOut),
        if (lastOrder != null) ...[
          const SizedBox(height: 18),
          _SectionLabel('Recent order'),
          const SizedBox(height: 10),
          Pressable(
            onTap: () => SwagNav.push(
              context,
              (_) => OrderPlacedScreen(order: lastOrder),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: SwagTheme.cardDecoration(radius: 20),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: SwagColors.mintSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SwagIcon('package', size: 20, color: SwagColors.mintDeep),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${lastOrder.id}',
                          style: SwagTheme.body(size: 13.5, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${lastOrder.itemCount} · ${lastOrder.methodLabel} · ₹${lastOrder.total.toStringAsFixed(0)}',
                          style: SwagTheme.body(size: 11.5, color: SwagColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  const SwagIcon('arrow-right', size: 15, color: SwagColors.inkFaint),
                ],
              ),
            ),
          ).animate(delay: 140.ms).fadeIn(duration: 420.ms).moveY(begin: 16, end: 0, duration: 420.ms, curve: Curves.easeOut),
        ],
        const SizedBox(height: 18),
        _SectionLabel('More for you'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: SwagColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SwagColors.line),
          ),
          child: Column(
            children: [
              _MenuRow(
                icon: 'location',
                tint: SwagColors.mint,
                label: 'Saved addresses',
                trailing: 'Phase 2',
                chip: true,
              ),
              const _Divider(),
              _MenuRow(
                icon: 'card',
                tint: SwagColors.lavender,
                label: 'Payment methods',
                trailing: 'Phase 2',
                chip: true,
              ),
              const _Divider(),
              _MenuRow(
                icon: 'shield',
                tint: SwagColors.butter,
                label: 'Help & support',
                onTap: () => _toast(context, 'Support desk opens with Phase 2.'),
              ),
              const _Divider(),
              _MenuRow(
                icon: 'sparkles',
                tint: SwagColors.accent,
                label: 'About SwagKart',
                onTap: () => _showAbout(context),
              ),
            ],
          ),
        ).animate(delay: 180.ms).fadeIn(duration: 420.ms).moveY(begin: 16, end: 0, duration: 420.ms, curve: Curves.easeOut),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: SwagColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SwagColors.line),
          ),
          child: Pressable(
            onTap: () => SwagNav.push(context, (_) => const AdminGate()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: SwagColors.butterSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SwagIcon('lock', size: 19, color: SwagColors.butterDeep),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin console',
                          style: TextStyle(
                            fontFamily: 'Baloo2',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: SwagColors.ink,
                          ),
                        ),
                        Text(
                          'Merchant dashboard · Phase 3',
                          style: TextStyle(fontSize: 11.5, color: SwagColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  const SwagIcon('arrow-right', size: 17, color: SwagColors.inkFaint),
                ],
              ),
            ),
          ),
        ).animate(delay: 220.ms).fadeIn(duration: 420.ms).moveY(begin: 16, end: 0, duration: 420.ms, curve: Curves.easeOut),
        const SizedBox(height: 22),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Made with ',
                style: SwagTheme.body(size: 11.5, color: SwagColors.inkFaint),
              ),
              const SwagIcon('heart-filled', size: 12, color: SwagColors.accent),
              const SizedBox(width: 4),
              Text(
                ' in India · v0.3.0',
                style: SwagTheme.body(size: 11.5, color: SwagColors.inkFaint),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: SwagTheme.body(
            size: 13,
            weight: FontWeight.w600,
            color: SwagColors.canvas,
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/logo.svg',
                width: 76,
                height: 76,
              ),
              const SizedBox(height: 14),
              Text(
                'SwagKart',
                style: SwagTheme.display(size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                'A playful Indian storefront demo. Phase 1 ships the '
                'storefront, discovery and bag — checkout, orders, '
                'accounts and the admin console follow.',
                textAlign: TextAlign.center,
                style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: SwagButton(
                  label: 'Love it',
                  icon: 'heart',
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White "member card" — avatar, identity, VIP chip and live stats.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.savedCount, required this.bagCount});

  final int savedCount;
  final int bagCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SwagColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: SwagColors.line),
        boxShadow: [
          BoxShadow(
            color: SwagColors.ink.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: SwagColors.accentSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SwagColors.accent.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: SwagIcon('user', size: 26, color: SwagColors.accentDeep),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aarav Sharma',
                      style: SwagTheme.display(size: 20),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'aarav.swag@example.in',
                      style: SwagTheme.body(size: 12, color: SwagColors.inkSoft),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/icons/logo.svg',
                width: 42,
                height: 42,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: SwagColors.butterSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwagIcon('fire', size: 12, color: SwagColors.butterDeep),
                    SizedBox(width: 5),
                    Text(
                      'VIP Swag Club',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: SwagColors.butterDeep,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'ID · SK-000214',
                style: SwagTheme.body(
                  size: 10.5,
                  weight: FontWeight.w700,
                  color: SwagColors.inkFaint,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: SwagColors.line,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatTile(value: '$savedCount', label: 'Saved'),
              const _StatDivider(),
              _StatTile(value: '$bagCount', label: 'In bag'),
              const _StatDivider(),
              _StatTile(value: '250', label: 'Rewards'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: SwagTheme.display(size: 19, weight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: SwagTheme.body(
              size: 10,
              weight: FontWeight.w600,
              color: SwagColors.inkFaint,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: 1,
        height: 26,
        color: SwagColors.line,
      ),
    );
  }
}

/// 2×2 tappable quick-action grid.
class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onOrders,
    required this.onWishlist,
    required this.onAddresses,
    required this.onSupport,
  });

  final VoidCallback onOrders;
  final VoidCallback onWishlist;
  final VoidCallback onAddresses;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SwagColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SwagColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _QuickTile(
                  icon: 'package',
                  tint: SwagColors.mist,
                  label: 'Orders',
                  onTap: onOrders,
                ),
              ),
              const _TileVGap(),
              Expanded(
                child: _QuickTile(
                  icon: 'heart-filled',
                  tint: SwagColors.blush,
                  label: 'Wishlist',
                  iconColor: SwagColors.blushDeep,
                  onTap: onWishlist,
                ),
              ),
            ],
          ),
          const _TileHGap(),
          Row(
            children: [
              Expanded(
                child: _QuickTile(
                  icon: 'location',
                  tint: SwagColors.mint,
                  label: 'Addresses',
                  onTap: onAddresses,
                ),
              ),
              const _TileVGap(),
              Expanded(
                child: _QuickTile(
                  icon: 'shield',
                  tint: SwagColors.butter,
                  label: 'Support',
                  onTap: onSupport,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.tint,
    required this.label,
    this.iconColor,
    required this.onTap,
  });

  final String icon;
  final Color tint;
  final String label;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SwagIcon(
                  icon,
                  size: 20,
                  color: iconColor ?? SwagColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              label,
              style: SwagTheme.body(size: 12, weight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileVGap extends StatelessWidget {
  const _TileVGap();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(width: 1, color: SwagColors.line),
    );
  }
}

class _TileHGap extends StatelessWidget {
  const _TileHGap();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(height: 1, color: SwagColors.line),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: SwagTheme.body(
        size: 11,
        weight: FontWeight.w800,
        color: SwagColors.inkFaint,
        letterSpacing: 1,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 62),
      child: Divider(height: 1, color: SwagColors.surfaceMist),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.tint,
    required this.label,
    this.trailing,
    this.chip = false,
    this.onTap,
  });

  final String icon;
  final Color tint;
  final String label;
  final String? trailing;
  final bool chip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SwagIcon(icon, size: 19, color: SwagColors.ink),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: SwagTheme.body(size: 14, weight: FontWeight.w700),
              ),
            ),
            if (trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: SwagColors.surfaceMist,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  trailing!,
                  style: SwagTheme.body(size: 10.5, weight: FontWeight.w800, color: SwagColors.inkSoft),
                ),
              ),
            const SizedBox(width: 8),
            if (!chip) const SwagIcon('arrow-right', size: 15, color: SwagColors.inkFaint),
          ],
        ),
      ),
    );
  }
}
