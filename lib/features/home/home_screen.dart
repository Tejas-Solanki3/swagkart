import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/chip.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/swag_icon.dart';
import '../../data/demo_data.dart';
import '../../data/models/product.dart';
import '../../state/app_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _heroImage = 0;
  Timer? _heroTimer;
  int _suggestion = 0;
  Timer? _suggestionTimer;
  bool _copied = false;
  static const _suggestions = [
    'hoodies',
    'retro runners',
    'wide jeans',
    'canvas totes',
    'chelsea boots',
  ];

  @override
  void initState() {
    super.initState();
    _heroTimer = Timer.periodic(const Duration(milliseconds: 4200), (_) {
      if (mounted) setState(() => _heroImage = (_heroImage + 1) % 3);
    });
    _suggestionTimer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (mounted) setState(() => _suggestion = (_suggestion + 1) % _suggestions.length);
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _suggestionTimer?.cancel();
    super.dispose();
  }

  void _copyCode(SwagAppStore store) {
    Clipboard.setData(const ClipboardData(text: 'SWAG15'));
    setState(() => _copied = true);
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = swagPad(size.width);
    return Consumer<SwagAppStore>(
      builder: (context, store, _) {
        final trending = store.byCategory(SwagCategory.allId).take(6).toList();
        final deals = store.products.where((p) => p.onSale).toList();
        final fresh = store.byCategory(SwagCategory.allId, sort: SortMode.rating);
        return ListView(
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 130),
          children: [
            _HomeHeader(
              onBag: () => store.requestTab(3),
              onBell: () => _notifyDrops(context),
            ),
            const SizedBox(height: 18),
            _SearchBar(
              suggestion: _suggestions[_suggestion],
              onTap: () => store.requestTab(2),
            ),
            const SizedBox(height: 18),
            _OfferCard(
              image: store.heroes[_heroImage].image,
              onExplore: () => store.requestTab(1),
            ),
            const SizedBox(height: 20),
            _CategoryRow(store: store),
            const SizedBox(height: 26),
            SectionHeader(
              title: 'Trending now',
              subtitle: 'What everyone is bagging this week',
              onSeeAll: () => store.requestTab(1),
            ),
            SizedBox(
              height: 268,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: trending.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) =>
                    ProductCard(product: trending[i], width: 172, stagger: i),
              ),
            ),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Steal the deals',
              subtitle: 'Mrp slashed, swag intact',
              onSeeAll: () => store.requestTab(1, category: 'deals'),
            ),
            _DealsStrip(deals: deals),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Fresh for you',
              subtitle: 'Top-rated picks from the whole catalog',
              onSeeAll: () => store.requestTab(1),
            ),
            _ResponsiveGrid(products: fresh, pad: pad),
            const SizedBox(height: 28),
            const _TrustStrip(),
            const SizedBox(height: 20),
            _PromoCard(copied: _copied, onCopy: () => _copyCode(store)),
          ],
        );
      },
    );
  }

  void _notifyDrops(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('You are all caught up — no new drops yet.')),
      );
  }
}

// ---------------------------------------------------------------------------

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onBag, required this.onBell});

  final VoidCallback onBag;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: SwagColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: SwagColors.line),
            boxShadow: [
              BoxShadow(
                color: SwagColors.ink.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/logo-mark.svg',
              width: 26,
              height: 26,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Swagstar',
                style: SwagTheme.display(size: 18),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  Text(
                    'Mumbai, IN',
                    style: SwagTheme.body(size: 12, weight: FontWeight.w700, color: SwagColors.inkSoft),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Free shipping over ₹999',
                      style: SwagTheme.body(size: 12, color: SwagColors.inkFaint),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Pressable(
          onTap: onBell,
          child: Container(
            width: 44,
            height: 44,
            decoration: SwagTheme.iconButtonDecoration(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: SwagIcon('bell', size: 19, color: SwagColors.ink),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: SwagColors.accent,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: SwagColors.surfaceMist, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate(
          onPlay: (c) => c.repeat(reverse: true),
          delay: 2400.ms,
        ).rotate(begin: -0.04, end: 0.04, duration: 700.ms),
        const SizedBox(width: 10),
        Pressable(
          onTap: onBag,
          child: Container(
            width: 44,
            height: 44,
            decoration: SwagTheme.iconButtonDecoration(),
            child: const Center(
              child: SwagIcon('bag', size: 19, color: SwagColors.ink),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.suggestion, required this.onTap});

  final String suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: SwagTheme.cardDecoration(radius: 999),
        child: Row(
          children: [
            const SizedBox(width: 18),
            const SwagIcon('search', size: 19, color: SwagColors.inkSoft),
            const SizedBox(width: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  'Search “$suggestion”…',
                  key: ValueKey(suggestion),
                  style: SwagTheme.body(size: 14, color: SwagColors.inkFaint),
                  maxLines: 1,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 22,
              color: SwagColors.line,
            ),
            const SizedBox(width: 14),
            const SwagIcon('filter', size: 18, color: SwagColors.inkSoft),
            const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Reference-style pastel offer card with a rotating product image.
class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.image, required this.onExplore});

  final String image;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        color: SwagColors.mistSoft,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: SwagColors.surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'NEW SEASON · SS26',
                    style: SwagTheme.body(
                      size: 9.5,
                      weight: FontWeight.w800,
                      color: SwagColors.mistDeep,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Get Special Offer',
                  style: SwagTheme.display(size: 16, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '40% OFF',
                  style: SwagTheme.display(
                    size: 27,
                    weight: FontWeight.w800,
                    color: SwagColors.ink,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 12),
                Pressable(
                  onTap: onExplore,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: SwagColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: SwagColors.ink.withValues(alpha: 0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Explore more',
                          style: SwagTheme.body(
                            size: 12.5,
                            weight: FontWeight.w700,
                            color: SwagColors.ink,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const SwagIcon('arrow-right', size: 14, color: SwagColors.ink),
                      ],
                    ),
                  ),
                ).animate(
                  onPlay: (c) => c.repeat(reverse: true),
                  delay: 600.ms,
                ).rotate(begin: -0.03, end: 0.03, duration: 900.ms),
              ],
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 96,
            height: 96,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Container(
                key: ValueKey(image),
                decoration: BoxDecoration(
                  color: SwagColors.photoMat,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SwagColors.surface),
                ),
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.store});

  final SwagAppStore store;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: store.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = store.categories[i];
          return SwagChip(
            label: cat.label,
            icon: cat.id == SwagCategory.allId ? null : cat.icon,
            selected: cat.id == SwagCategory.allId,
            onTap: () {
              if (cat.id == SwagCategory.allId) {
                store.requestTab(1);
              } else {
                store.requestTab(1, category: cat.id);
              }
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _DealsStrip extends StatelessWidget {
  const _DealsStrip({required this.deals});

  final List<Product> deals;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: deals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final p = deals[i];
          return Container(
            width: 220,
            decoration: SwagTheme.cardDecoration(radius: 22),
            child: Row(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SwagColors.photoMat,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(p.image, fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: SwagTheme.display(size: 13.5, weight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                inr(p.price),
                                style: SwagTheme.display(size: 15, weight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                inr(p.mrp!),
                                style: SwagTheme.body(
                                  size: 10.5,
                                  color: SwagColors.inkFaint,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: SwagColors.accentSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SwagIcon('bolt', size: 12, color: SwagColors.accentDeep),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Save ${inr(p.savings)}',
                                  style: SwagTheme.body(
                                    size: 10.5,
                                    weight: FontWeight.w800,
                                    color: SwagColors.accentDeep,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.products, required this.pad});

  final List<Product> products;
  final double pad;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - pad * 2;
    final cols = swagColumns(width);
    final shown = products.take(cols * 2).toList();
    final rows = <List<Product>>[
      for (var i = 0; i < shown.length; i += cols)
        shown.sublist(i, i + cols > shown.length ? shown.length : i + cols),
    ];
    return Column(
      children: [
        for (var r = 0; r < rows.length; r++)
          Padding(
            padding: EdgeInsets.only(top: r == 0 ? 0 : 14),
            child: Row(
              children: [
                for (var c = 0; c < rows[r].length; c++) ...[
                  if (c > 0) const SizedBox(width: 14),
                  Expanded(child: ProductCard(product: rows[r][c], stagger: r * cols + c)),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('truck', 'Free shipping', 'On orders over ₹999', SwagColors.mistSoft, SwagColors.mistDeep),
      ('shield', '7-day returns', 'No questions, no drama', SwagColors.mintSoft, SwagColors.mintDeep),
      ('bolt', 'UPI & COD', 'Pay your way, safely', SwagColors.butterSoft, SwagColors.butterDeep),
    ];
    return Row(
      children: [
        for (final (icon, title, sub, tint, tintDeep) in items)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: SwagTheme.cardDecoration(radius: 20),
              child: Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: tint,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SwagIcon(icon, size: 19, color: tintDeep),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: SwagTheme.body(size: 11.5, weight: FontWeight.w800),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: SwagTheme.body(size: 10, color: SwagColors.inkSoft),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.copied, required this.onCopy});

  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: SwagTheme.cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: SwagColors.lavenderSoft,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SwagIcon('gift', size: 21, color: SwagColors.lavenderDeep),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First order perk',
                  style: SwagTheme.display(size: 15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Flat 15% off your very first bag.',
                  style: SwagTheme.body(size: 12, color: SwagColors.inkSoft),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: copied
                ? Container(
                    key: const ValueKey('copied'),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: SwagColors.mintSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SwagIcon('check', size: 14, color: SwagColors.mintDeep),
                        const SizedBox(width: 5),
                        Text(
                          'Copied!',
                          style: SwagTheme.body(
                            size: 12,
                            weight: FontWeight.w800,
                            color: SwagColors.mintDeep,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    key: const ValueKey('code'),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                    decoration: BoxDecoration(
                      color: SwagColors.canvas,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: SwagColors.ink.withValues(alpha: 0.35),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Text(
                      'SWAG15',
                      style: SwagTheme.display(
                        size: 13,
                        weight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Pressable(
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              decoration: BoxDecoration(
                color: SwagColors.ink,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwagIcon(
                    copied ? 'check' : 'copy',
                    size: 14,
                    color: copied ? SwagColors.mint : Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    copied ? 'Copied' : 'Copy',
                    style: SwagTheme.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: Colors.white,
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
