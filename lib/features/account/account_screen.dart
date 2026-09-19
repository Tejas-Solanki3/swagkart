// =============================================================================
// File: lib/features/account/account_screen.dart
// Purpose: User account management view displaying user profile details, loyalty
//          points card, active orders, saved addresses, and navigation to admin or auth.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swag_button.dart';
import '../../core/widgets/swag_icon.dart';
import '../../core/widgets/swag_logo.dart';
import '../../state/app_store.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

/// Account tab — premium light cards, live order + wishlist shortcuts.
///
/// Features:
/// - Profile identity banner with edit shortcut
/// - Loyalty SwagPoints rewards card
/// - Last order tracking card
/// - Admin console gateway for authorized personnel
/// - Sign out and authentication toggles
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});


  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<SwagAppStore>();
    final saved = store.wishlistProducts;
    final order = store.lastOrder;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
      children: [
        Row(
          children: [
            const SwagLogo(size: 34, showText: true),
            const SizedBox(width: 12),
            Container(width: 1, height: 22, color: SwagColors.line),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Your Account', style: SwagTheme.display(size: 24)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Profile card
        if (store.isLoggedIn)
          Container(
                padding: const EdgeInsets.all(18),
                decoration: SwagTheme.cardDecoration(
                  radius: 26,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [SwagColors.accentSoft, SwagColors.butterSoft],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: SwagColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: SwagColors.line,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          store.currentUser?.initials ?? 'SK',
                          style: SwagTheme.display(
                            size: 20,
                            color: SwagColors.accentDeep,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.currentUser?.name ?? 'Swag Member',
                            style: SwagTheme.display(size: 20),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            store.currentUser?.email ?? '',
                            style: SwagTheme.body(
                              size: 12,
                              color: SwagColors.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Pressable(
                                onTap: store.isAdmin
                                    ? () => SwagNav.push(
                                        context,
                                        (_) => const AdminDashboardScreen(),
                                      )
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: SwagColors.surface,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SwagIcon(
                                        store.isAdmin ? 'lock' : 'fire',
                                        size: 12,
                                        color: store.isAdmin
                                            ? SwagColors.lavenderDeep
                                            : SwagColors.accentDeep,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        store.isAdmin
                                            ? 'Admin Console'
                                            : 'VIP Swag Club',
                                        style: SwagTheme.body(
                                          size: 10.5,
                                          weight: FontWeight.w800,
                                          color: SwagColors.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Pressable(
                                onTap: () => SwagNav.push(
                                  context,
                                  (_) => const EditProfileScreen(),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: SwagColors.ink,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.edit_outlined,
                                        size: 12,
                                        color: SwagColors.canvas,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Edit',
                                        style: SwagTheme.body(
                                          size: 10.5,
                                          weight: FontWeight.w700,
                                          color: SwagColors.canvas,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.96, 0.96),
                end: const Offset(1, 1),
                duration: 450.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 350.ms)
        else
          Container(
                padding: const EdgeInsets.all(20),
                decoration: SwagTheme.cardDecoration(
                  radius: 26,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [SwagColors.surface, SwagColors.butterSoft],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: SwagColors.canvas,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SwagIcon(
                              'sparkles',
                              size: 26,
                              color: SwagColors.accentDeep,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to SwagKart',
                                style: SwagTheme.display(size: 19),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sign in to track orders, save items & get drops.',
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
                    const SizedBox(height: 16),
                    SwagButton(
                      label: 'Sign In / Join the Club',
                      icon: 'arrow-right',
                      height: 46,
                      onTap: () =>
                          SwagNav.push(context, (_) => const LoginScreen()),
                    ),
                  ],
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.96, 0.96),
                duration: 450.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 350.ms),
        const SizedBox(height: 16),
        // SwagPoints Loyalty Container
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: SwagColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SwagColors.butter.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: SwagColors.ink.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: SwagColors.butter,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🪙', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SwagPoints Loyalty',
                          style: SwagTheme.display(size: 16),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '10% cashback points on every purchase',
                          style: SwagTheme.body(
                            size: 11.5,
                            color: SwagColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: SwagColors.butterSoft,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: SwagColors.butter.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${store.swagPoints} PTS',
                      style: SwagTheme.body(
                        size: 12,
                        weight: FontWeight.w800,
                        color: SwagColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SwagColors.canvas,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SwagColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      size: 20,
                      color: SwagColors.accentDeep,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Redeem points directly on product details or at bag checkout for instant discounts.',
                        style: SwagTheme.body(
                          size: 11.5,
                          color: SwagColors.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Stats trio
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: 'package',
                tint: SwagColors.mist,
                value: order == null
                    ? '—'
                    : '#${order.id.substring(order.id.length - 4)}',
                label: 'Last order',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: 'heart-filled',
                tint: SwagColors.blush,
                value: '${saved.length}',
                label: 'Saved items',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: 'tag',
                tint: SwagColors.mint,
                value: order == null ? '—' : inr(order.total),
                label: 'Spent',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionLabel('Saved & orders'),
        const SizedBox(height: 10),
        Container(
          decoration: SwagTheme.cardDecoration(radius: 24),
          child: Column(
            children: [
              Pressable(
                onTap: () => store.requestTab(2),
                child: _MenuRow(
                  icon: 'heart',
                  tint: SwagColors.blush,
                  label: 'Saved for later',
                  trailing: saved.isEmpty
                      ? 'Start loving things'
                      : '$saved.length saved',
                  trailingStyle: saved.isEmpty
                      ? SwagTheme.body(size: 12, color: SwagColors.inkFaint)
                      : SwagTheme.body(
                          size: 12,
                          weight: FontWeight.w800,
                          color: SwagColors.blushDeep,
                        ),
                ),
              ),
              const _Divider(),
              Pressable(
                onTap: () => _toast(
                  context,
                  order == null
                      ? 'No orders yet — your first drop is one tap away.'
                      : 'Order #${order.id} is being prepped — we’ll ping you when it ships.',
                ),
                child: _MenuRow(
                  icon: 'package',
                  tint: SwagColors.mist,
                  label: 'My orders & tracking',
                  trailing: order == null ? 'Coming up' : 'On the way',
                  chip: order == null,
                ),
              ),
              const _Divider(),
              Pressable(
                onTap: () {
                  if (store.isLoggedIn) {
                    SwagNav.push(context, (_) => const EditProfileScreen());
                  } else {
                    SwagNav.push(context, (_) => const LoginScreen());
                  }
                },
                child: _MenuRow(
                  icon: 'location',
                  tint: SwagColors.peach,
                  label: 'Saved addresses',
                  trailing: store.currentUser?.city.isNotEmpty == true
                      ? store.currentUser!.city
                      : (store.isLoggedIn ? 'Edit' : 'Sign in'),
                  chip: !store.isLoggedIn,
                ),
              ),
              const _Divider(),
              _MenuRow(
                icon: 'card',
                tint: SwagColors.lavender,
                label: 'Payment methods',
                trailing: 'Saved at checkout',
              ),
              const _Divider(),
              _MenuRow(
                icon: 'shield',
                tint: SwagColors.mint,
                label: 'Help & support',
                onTap: () => _toast(
                  context,
                  'Support replies within a few hours — you’re in good company.',
                ),
              ),
              const _Divider(),
              _MenuRow(
                icon: 'sparkles',
                tint: SwagColors.butter,
                label: 'About SwagKart',
                onTap: () => _showAbout(context),
              ),
            ],
          ),
        ),
        if (store.isLoggedIn) ...[
          const SizedBox(height: 16),
          Container(
            decoration: SwagTheme.cardDecoration(radius: 20),
            child: Pressable(
              onTap: () => _confirmSignOut(context, store),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: SwagColors.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: SwagColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Log Out',
                            style: SwagTheme.body(
                              size: 14.5,
                              weight: FontWeight.w800,
                              color: SwagColors.accent,
                            ),
                          ),
                          Text(
                            'Sign out of your account on this device',
                            style: SwagTheme.body(
                              size: 11.5,
                              color: SwagColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: SwagColors.inkFaint,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 22),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Made with ',
                style: SwagTheme.body(size: 11.5, color: SwagColors.inkFaint),
              ),
              const SwagIcon(
                'heart-filled',
                size: 12,
                color: SwagColors.accent,
              ),
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
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [SwagColors.accent, SwagColors.peach],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SwagIcon('bag', size: 30, color: SwagColors.surface),
                ),
              ),
              const SizedBox(height: 14),
              Text('SwagKart', style: SwagTheme.display(size: 24)),
              const SizedBox(height: 6),
              const Text(
                'A playful Indian storefront. The store, discovery, bag and '
                'checkout are live — the merchant console is next on the board.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: SwagColors.inkSoft,
                  height: 1.5,
                ),
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

  void _confirmSignOut(BuildContext context, SwagAppStore store) {
    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: SwagColors.surface,
        title: Text('Sign Out?', style: SwagTheme.display(size: 20)),
        content: Text(
          'Are you sure you want to sign out of your SwagKart account?',
          style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlg).pop(),
            child: Text(
              'Cancel',
              style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SwagColors.accent,
              foregroundColor: SwagColors.ink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              Navigator.of(dlg).pop();
              await store.logout();
              if (context.mounted) {
                _toast(context, 'Signed out of SwagKart.');
              }
            },
            child: Text(
              'Sign Out',
              style: SwagTheme.body(size: 13, weight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.tint,
    required this.value,
    required this.label,
  });

  final String icon;
  final Color tint;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: SwagTheme.cardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SwagIcon(icon, size: 14, color: SwagColors.ink),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: SwagTheme.display(size: 14, weight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: SwagTheme.body(size: 10, color: SwagColors.inkSoft),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
      child: Divider(height: 1, color: SwagColors.line),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.tint,
    required this.label,
    this.trailing,
    this.trailingStyle,
    this.chip = false,
    this.onTap,
  });

  final String icon;
  final Color tint;
  final String label;
  final String? trailing;
  final TextStyle? trailingStyle;
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
              chip
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: SwagColors.surfaceMist,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        trailing!,
                        style: SwagTheme.body(
                          size: 10.5,
                          weight: FontWeight.w800,
                          color: SwagColors.inkSoft,
                        ),
                      ),
                    )
                  : Text(
                      trailing!,
                      style:
                          trailingStyle ??
                          SwagTheme.body(size: 12, color: SwagColors.inkFaint),
                    ),
            const SizedBox(width: 8),
            if (!chip)
              const SwagIcon(
                'arrow-right',
                size: 15,
                color: SwagColors.inkFaint,
              ),
          ],
        ),
      ),
    );
  }
}
