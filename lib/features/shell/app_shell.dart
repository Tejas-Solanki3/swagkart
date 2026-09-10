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
import '../search/search_screen.dart';

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
      const SearchScreen(),
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
    _TabSpec('home', 'home-filled', 'Home'),
    _TabSpec('grid', 'grid-filled', 'Catalog'),
    _TabSpec('search', 'search', 'Search', special: true),
    _TabSpec('bag', 'bag-filled', 'Bag'),
    _TabSpec('user', 'user-filled', 'Account'),
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
            height: 68,
            decoration: BoxDecoration(
              color: SwagColors.paper,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: SwagColors.sand),
              boxShadow: [
                BoxShadow(
                  color: SwagColors.ink.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Sliding indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutBack,
                  left: index * slot + (slot - 54) / 2,
                  top: index == 2 ? -6 : 8,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: index == 2 ? SwagColors.tangerine : SwagColors.tangerineSoft,
                      borderRadius: BorderRadius.circular(20),
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
                          isCenter: i == 2,
                          onTap: () => onSelected(i),
                        ),
                      ),
                  ],
                ),
                // Cart badge
                if (cartCount > 0)
                  Positioned(
                    right: slot * 3 + slot / 2 + 6,
                    top: 14,
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
  const _TabSpec(this.icon, this.iconFilled, this.label, {this.special = false});
  final String icon;
  final String iconFilled;
  final String label;
  final bool special;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.active,
    required this.isCenter,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool active;
  final bool isCenter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        (active && isCenter) ? Colors.white : (active ? SwagColors.tangerine : SwagColors.inkFaint);
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween<double>(begin: 0.6, end: 1).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: SwagIcon(
              active && !isCenter ? spec.iconFilled : (isCenter ? spec.icon : spec.icon),
              key: ValueKey('${spec.icon}-$active-$isCenter'),
              size: isCenter ? 24 : 22,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            spec.label,
            style: SwagTheme.body(
              size: 10,
              weight: active ? FontWeight.w700 : FontWeight.w500,
              color: (active && isCenter)
                  ? SwagColors.tangerine
                  : (active ? SwagColors.ink : SwagColors.inkFaint),
            ),
          ),
        ],
      ),
    );
  }
}


