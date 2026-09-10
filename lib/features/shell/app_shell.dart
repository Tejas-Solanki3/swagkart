import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/count_badge.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swag_icon.dart';
import '../../state/app_store.dart';
import '../account/account_screen.dart';
import '../bag/bag_screen.dart';
import '../catalog/catalog_screen.dart';
import '../home/home_screen.dart';
import '../wishlist/wishlist_screen.dart';

/// Root 5-tab shell with a floating pill bottom nav.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      const CatalogScreen(),
      const WishlistScreen(),
      const BagScreen(),
      const AccountScreen(),
    ];

    return Consumer<SwagAppStore>(
      builder: (context, store, _) {
        if (store.tabTarget != null && store.tabTarget != _index) {
          final target = store.tabTarget!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _index = target);
            store.consumeTabRequest();
          });
        }
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: IndexedStack(index: _index, children: pages),
          ),
          bottomNavigationBar: _SwagBottomNav(
            index: _index,
            cartCount: store.cartCount,
            onSelected: (i) => setState(() => _index = i),
          ),
        );
      },
    );
  }
}

class _SwagBottomNav extends StatelessWidget {
  const _SwagBottomNav({
    required this.index,
    required this.cartCount,
    required this.onSelected,
  });

  final int index;
  final int cartCount;
  final ValueChanged<int> onSelected;

  static const _tabs = <_TabSpec>[
    _TabSpec('home', 'Home'),
    _TabSpec('grid', 'Catalog'),
    _TabSpec('heart', 'Wishlist'),
    _TabSpec('bag', 'Bag'),
    _TabSpec('user', 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final slot = w / _tabs.length;
          return Container(
            height: 64,
            decoration: BoxDecoration(
              color: SwagColors.ink,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: SwagColors.ink.withValues(alpha: 0.38),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Sliding white pill indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutBack,
                  left: index * slot + 5,
                  top: 8,
                  width: slot - 10,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      color: SwagColors.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < _tabs.length; i++)
                      Expanded(
                        child: _NavItem(
                          spec: _tabs[i],
                          active: i == index,
                          onTap: () => onSelected(i),
                        ),
                      ),
                  ],
                ),
                // Bag badge — sits on the Bag tab (index 3)
                if (cartCount > 0)
                  Positioned(
                    right: slot * 1.5 - 10,
                    top: 8,
                    child: CountBadge(count: cartCount),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.icon, this.label);
  final String icon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.active,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Same icon in both states — only the tone changes.
    // Active: ink on the sliding white pill. Inactive: white on the ink bar.
    final iconColor = active ? SwagColors.ink : Colors.white.withValues(alpha: 0.5);
    final labelColor = active ? SwagColors.ink : Colors.white.withValues(alpha: 0.55);
    return Pressable(
      onTap: onTap,
      scale: 0.94,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SwagIcon(
            spec.icon,
            size: 21,
            color: iconColor,
          ),
          const SizedBox(height: 2),
          Text(
            spec.label,
            style: SwagTheme.body(
              size: 10,
              weight: active ? FontWeight.w700 : FontWeight.w500,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}


