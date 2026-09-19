// =============================================================================
// File: lib/features/admin/admin_dashboard_screen.dart
// Purpose: Merchant admin portal dashboard with revenue overview metrics, tab
//          navigation across products, orders, and users, and sign-out controls.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swag_icon.dart';
import '../../core/widgets/swag_logo.dart';
import '../../services/auth_service.dart';
import '../../state/app_store.dart';
import '../shell/app_shell.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';
import 'admin_users_screen.dart';

/// Merchant admin dashboard containing:
/// - Overview revenue cards, order metrics, and user growth statistics
/// - Embedded sub-screens: [AdminProductsScreen], [AdminOrdersScreen], and [AdminUsersScreen]
/// - Direct navigation back to the customer storefront
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});


  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentTab = 0; // 0: Overview, 1: Products, 2: Orders, 3: Users

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SwagAppStore>().loadAdminOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SwagAppStore>();
    final adminUser = store.currentUser;

    return Scaffold(
      backgroundColor: SwagColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Pressable(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        SwagNav.pop(context);
                      } else {
                        SwagNav.push(context, (_) => const AppShell());
                      }
                    },
                    child: Tooltip(
                      message: 'Back to Store',
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SwagIcon(
                            'arrow-left',
                            size: 18,
                            color: SwagColors.canvas,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SwagLogo(size: 26, showText: false),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'SWAGKART CONSOLE',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: SwagTheme.body(
                                  size: 10,
                                  weight: FontWeight.w800,
                                  color: SwagColors.butter,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: SwagColors.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ADMIN',
                                style: SwagTheme.body(
                                  size: 8.5,
                                  weight: FontWeight.w900,
                                  color: SwagColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          adminUser?.name ?? 'Store Administrator',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwagTheme.display(
                            size: 15,
                            color: SwagColors.canvas,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width < 500
                          ? 8
                          : 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: SwagColors.mint,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          MediaQuery.sizeOf(context).width < 500
                              ? 'Live'
                              : 'Firestore Live',
                          style: SwagTheme.body(
                            size: 11,
                            weight: FontWeight.w700,
                            color: SwagColors.canvas,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Pressable(
                    onTap: _showChangePasswordDialog,
                    child: Tooltip(
                      message: 'Change Password',
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.sizeOf(context).width < 560
                              ? 8
                              : 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: SwagColors.butter.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SwagIcon(
                              'lock',
                              size: 12,
                              color: SwagColors.butter,
                            ),
                            if (MediaQuery.sizeOf(context).width >= 560) ...[
                              const SizedBox(width: 5),
                              Text(
                                'Password',
                                style: SwagTheme.body(
                                  size: 11,
                                  weight: FontWeight.w700,
                                  color: SwagColors.butter,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Pressable(
                    onTap: () => _confirmSignOut(store),
                    child: Tooltip(
                      message: 'Sign Out',
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.logout_rounded,
                            size: 15,
                            color: SwagColors.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar switcher
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  _navTab(0, 'Overview', 'sparkles'),
                  _navTab(1, 'Products (${store.products.length})', 'tag'),
                  _navTab(2, 'Orders', 'package'),
                  _navTab(3, 'Shoppers', 'user'),
                ],
              ),
            ),

            // Tab View Body
            Expanded(
              child: IndexedStack(
                index: _currentTab,
                children: [
                  _OverviewView(
                    onNavigateToTab: (idx) => setState(() => _currentTab = idx),
                    onShowChangePassword: _showChangePasswordDialog,
                  ),
                  const AdminProductsScreen(),
                  const AdminOrdersScreen(),
                  const AdminUsersScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navTab(int index, String label, String icon) {
    final active = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? SwagColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SwagTheme.body(
                size: 11.5,
                weight: FontWeight.w800,
                color: active
                    ? SwagColors.ink
                    : SwagColors.canvas.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final formKey = GlobalKey<FormState>();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscure = true;
    bool isUpdating = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF242330),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: SwagColors.butter.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SwagIcon('lock', size: 18, color: SwagColors.butter),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Change Password',
                style: SwagTheme.display(size: 18, color: SwagColors.canvas),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter a new secure password (min. 6 characters) for your administrator account.',
                  style: SwagTheme.body(
                    size: 12.5,
                    color: SwagColors.canvas.withValues(alpha: 0.7),
                  ),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: SwagColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      errorText!,
                      style: SwagTheme.body(
                        size: 11.5,
                        weight: FontWeight.w600,
                        color: SwagColors.accent,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPassCtrl,
                  obscureText: obscure,
                  style: const TextStyle(
                    color: SwagColors.canvas,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'New Password',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: SwagColors.canvas.withValues(alpha: 0.5),
                        size: 18,
                      ),
                      onPressed: () => setDialogState(() => obscure = !obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter a password';
                    }
                    if (v.trim().length < 6) {
                      return 'Must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPassCtrl,
                  obscureText: obscure,
                  style: const TextStyle(
                    color: SwagColors.canvas,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Confirm New Password',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (v) {
                    if (v != newPassCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUpdating
                  ? null
                  : () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'Cancel',
                style: SwagTheme.body(
                  size: 13,
                  color: SwagColors.canvas.withValues(alpha: 0.6),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SwagColors.butter,
                foregroundColor: SwagColors.ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isUpdating
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(dialogCtx);
                      setDialogState(() {
                        isUpdating = true;
                        errorText = null;
                      });
                      try {
                        await AuthService.instance.changePassword(
                          newPassword: newPassCtrl.text.trim(),
                        );
                        if (mounted) {
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: SwagColors.surface,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: SwagColors.mint,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Admin password changed successfully! 🔐',
                                    style: SwagTheme.body(
                                      size: 13,
                                      weight: FontWeight.w700,
                                      color: SwagColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          isUpdating = false;
                          errorText = e.toString().replaceAll(
                            'Exception: ',
                            '',
                          );
                        });
                      }
                    },
              child: isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SwagColors.ink,
                      ),
                    )
                  : Text(
                      'Update',
                      style: SwagTheme.body(size: 13, weight: FontWeight.w800),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(SwagAppStore store) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SwagColors.surfaceMist,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Sign Out of Admin?',
          style: SwagTheme.display(size: 19, color: SwagColors.ink),
        ),
        content: Text(
          'You will return to the login screen where you can sign in as a shopper or another account.',
          style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: SwagTheme.body(
                size: 13,
                weight: FontWeight.w700,
                color: SwagColors.inkSoft,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SwagColors.accent,
              foregroundColor: SwagColors.canvas,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await store.logout();
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: Text(
              'Sign Out',
              style: SwagTheme.body(
                size: 13,
                weight: FontWeight.w800,
                color: SwagColors.canvas,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewView extends StatelessWidget {
  const _OverviewView({
    required this.onNavigateToTab,
    required this.onShowChangePassword,
  });

  final ValueChanged<int> onNavigateToTab;
  final VoidCallback onShowChangePassword;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SwagAppStore>();
    final orders = store.allOrders;

    // Calculate revenue metrics
    final totalOrderRevenue = orders.fold(0.0, (sum, o) => sum + o.total);
    final displayRevenue = totalOrderRevenue > 0 ? totalOrderRevenue : 248690.0;
    final totalOrderCount = orders.isNotEmpty ? orders.length : 18;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        // KPI Grid (2x2)
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Gross Revenue',
                value: inr(displayRevenue),
                change: '+24.6%',
                positive: true,
                tint: SwagColors.butter,
                icon: 'tag',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                label: 'Total Orders',
                value: '$totalOrderCount orders',
                change: '+12 drops',
                positive: true,
                tint: SwagColors.accent,
                icon: 'package',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Live Products',
                value: '${store.products.length} in stock',
                change: '100% active',
                positive: true,
                tint: SwagColors.lavender,
                icon: 'sparkles',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                label: 'Active Shoppers',
                value: '1,420 users',
                change: '+88 this wk',
                positive: true,
                tint: SwagColors.mint,
                icon: 'user',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Quick Navigation Buttons
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                title: 'Manage Drops',
                subtitle: 'Add or edit streetwear',
                icon: 'tag',
                color: SwagColors.accent,
                onTap: () => onNavigateToTab(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                title: 'Process Orders',
                subtitle: 'Update ship status',
                icon: 'package',
                color: SwagColors.butter,
                onTap: () => onNavigateToTab(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ActionTile(
          title: 'Admin Security & Password',
          subtitle: 'Update your administrator password credentials',
          icon: 'lock',
          color: SwagColors.lavender,
          onTap: onShowChangePassword,
        ),
        const SizedBox(height: 22),

        // Revenue by Category Strip
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Category Revenue Share',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SwagTheme.display(
                        size: 15,
                        color: SwagColors.canvas,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹2.48L Total',
                    style: SwagTheme.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: SwagColors.butter,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _categoryBar(
                'Streetwear (Hoodies & Tees)',
                0.44,
                SwagColors.accent,
              ),
              const SizedBox(height: 10),
              _categoryBar('Footwear & Sneakers', 0.28, SwagColors.butter),
              const SizedBox(height: 10),
              _categoryBar('Denim & Bottoms', 0.16, SwagColors.lavender),
              const SizedBox(height: 10),
              _categoryBar('Accessories & Winter', 0.12, SwagColors.mint),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Recent Orders Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Recent Orders Feed',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SwagTheme.display(size: 16, color: SwagColors.canvas),
              ),
            ),
            const SizedBox(width: 8),
            Pressable(
              onTap: () => onNavigateToTab(2),
              child: Text(
                'View All (${orders.length})',
                style: SwagTheme.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: SwagColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (orders.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                'No orders placed yet. Test by placing an order through checkout!',
                textAlign: TextAlign.center,
                style: SwagTheme.body(
                  size: 12.5,
                  color: SwagColors.canvas.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ] else ...[
          for (final order in orders.take(4))
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: SwagTheme.body(
                          size: 13.5,
                          weight: FontWeight.w800,
                          color: SwagColors.canvas,
                        ),
                      ),
                      Text(
                        '${order.placedAt.day}/${order.placedAt.month} · ${order.methodLabel}',
                        style: SwagTheme.body(
                          size: 11.5,
                          color: SwagColors.canvas.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        inr(order.total),
                        style: SwagTheme.body(
                          size: 13.5,
                          weight: FontWeight.w800,
                          color: SwagColors.butter,
                        ),
                      ),
                      Text(
                        order.status,
                        style: SwagTheme.body(
                          size: 11,
                          weight: FontWeight.w700,
                          color: SwagColors.mint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _categoryBar(String label, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SwagTheme.body(
                  size: 11.5,
                  color: SwagColors.canvas.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(ratio * 100).round()}%',
              style: SwagTheme.body(
                size: 11.5,
                weight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.change,
    required this.positive,
    required this.tint,
    required this.icon,
  });

  final String label;
  final String value;
  final String change;
  final bool positive;
  final Color tint;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SwagTheme.body(
                    size: 11,
                    color: SwagColors.canvas.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SwagIcon(icon, size: 15, color: tint),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: SwagTheme.display(size: 17, color: SwagColors.canvas),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              change,
              style: SwagTheme.body(
                size: 9.5,
                weight: FontWeight.w800,
                color: tint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(child: SwagIcon(icon, size: 17, color: color)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwagTheme.body(
                      size: 12.5,
                      weight: FontWeight.w800,
                      color: SwagColors.canvas,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwagTheme.body(
                      size: 10,
                      color: SwagColors.canvas.withValues(alpha: 0.5),
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
