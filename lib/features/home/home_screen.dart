import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/swag_icon.dart';
import '../../data/models/product.dart';
import '../../data/demo_data.dart';
import '../../state/app_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _heroController = PageController();
  int _heroPage = 0;
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
      if (mounted && _heroController.hasClients) {
        final next = (_heroPage + 1) % 3;
        _heroController.animateToPage(
          next,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutCubic,
        );
      }
    });
    _suggestionTimer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (mounted) setState(() => _suggestion = (_suggestion + 1) % _suggestions.length);
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _suggestionTimer?.cancel();
    _heroController.dispose();
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
          padding: EdgeInsets.fromLTRB(pad, 10, pad, 130),
          children: [
            _HomeHeader(onAccount: () => store.requestTab(4)),
            const SizedBox(height: 16),
            _SearchBar(
              suggestion: _suggestions[_suggestion],
              onTap: () => store.requestTab(2),
            ),
            const SizedBox(height: 18),
            _HeroCarousel(
              controller: _heroController,
              page: _heroPage,
              onPageChanged: (p) => setState(() => _heroPage = p),
              store: store,
            ),
            const SizedBox(height: 24),
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
            _TrustStrip(),
            const SizedBox(height: 20),
            _PromoBanner(store: store, copied: _copied, onCopy: () => _copyCode(store)),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onAccount});

  final VoidCallback onAccount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Pressable(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
              decoration: BoxDecoration(
                color: SwagColors.paper,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: SwagColors.sand),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SwagIcon('location', size: 15, color: SwagColors.tangerine),
                  const SizedBox(width: 6),
                  Text(
                    'Mumbai, IN',
                    style: SwagTheme.body(size: 12, weight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),
                  const SwagIcon('chevron-down', size: 13, color: SwagColors.inkSoft),
                ],
              ),
            ),
          ),
          const Spacer(),
          Pressable(
            onTap: () {},
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: SwagColors.paper,
                shape: BoxShape.circle,
                border: Border.all(color: SwagColors.sand),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: SwagIcon('bell', size: 19, color: SwagColors.ink),
                  ),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: SwagColors.tangerine,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: SwagColors.paper, width: 1.5),
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
            onTap: onAccount,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [SwagColors.tangerine, SwagColors.butter],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SwagIcon('user', size: 19, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
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
        height: 56,
        decoration: BoxDecoration(
          color: SwagColors.paper,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SwagColors.sand),
          boxShadow: [
            BoxShadow(
              color: SwagColors.ink.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const SwagIcon('search', size: 20, color: SwagColors.inkSoft),
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
                  'Search “$suggestion”',
                  key: ValueKey(suggestion),
                  style: SwagTheme.body(size: 14, color: SwagColors.inkFaint),
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: SwagColors.tangerine,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SwagIcon('arrow-right', size: 17, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _HeroCarousel extends StatelessWidget {
  const _HeroCarousel({
    required this.controller,
    required this.page,
    required this.onPageChanged,
    required this.store,
  });

  final PageController controller;
  final int page;
  final ValueChanged<int> onPageChanged;
  final SwagAppStore store;

  @override
  Widget build(BuildContext context) {
    final heroes = store.heroes;
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: width < 640 ? 232 : 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
        PageView.builder(
          controller: controller,
          onPageChanged: onPageChanged,
          itemCount: heroes.length,
          itemBuilder: (context, i) {
            final hero = heroes[i];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(hero.image, fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xB3221A13),
                        ],
                        stops: [0.35, 1],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: hero.accent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              hero.kicker.toUpperCase(),
                              style: SwagTheme.body(
                                size: 10,
                                weight: FontWeight.w800,
                                color: SwagColors.ink,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            hero.title,
                            style: SwagTheme.display(
                              size: 25,
                              color: Colors.white,
                              height: 1.1,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            hero.subtitle,
                            style: SwagTheme.body(
                              size: 12.5,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 14),
                          Pressable(
                            onTap: () => store.requestTab(1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: SwagColors.cream,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    hero.cta,
                                    style: SwagTheme.display(
                                      size: 14,
                                      weight: FontWeight.w700,
                                      color: SwagColors.ink,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const SwagIcon('arrow-right', size: 15, color: SwagColors.ink),
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
                  ),
                ],
              ),
            );
          },
        ),
        // Dots
        Positioned(
          bottom: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(heroes.length, (i) {
              final active = i == page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active ? SwagColors.cream : Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
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
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: store.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = store.categories[i];
          return Pressable(
            onTap: () {
              if (cat.id == SwagCategory.allId) {
                store.requestTab(1);
              } else {
                store.requestTab(1, category: cat.id);
              }
            },
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cat.tint.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                    border: Border.all(color: cat.tint.withValues(alpha: 0.5), width: 1.4),
                  ),
                  child: Center(
                    child: SwagIcon(cat.icon, size: 24, color: cat.tint),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  cat.label,
                  style: SwagTheme.body(size: 11, weight: FontWeight.w700),
                  maxLines: 1,
                ),
              ],
            ),
          ).animate(
            delay: (i * 70).ms,
          ).scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 480.ms, curve: Curves.easeOutBack).fadeIn(duration: 300.ms);
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
            decoration: BoxDecoration(
              color: SwagColors.paper,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: SwagColors.sand),
            ),
            child: Row(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SwagColors.butterSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(p.image, fit: BoxFit.contain),
                    ),
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
                            Text(
                              inr(p.price),
                              style: SwagTheme.display(size: 15, weight: FontWeight.w800),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              inr(p.mrp!),
                              style: SwagTheme.body(
                                size: 10.5,
                                color: SwagColors.inkFaint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: SwagColors.tangerineSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SwagIcon('bolt', size: 12, color: SwagColors.tangerineDeep),
                              const SizedBox(width: 4),
                              Text(
                                'Save ${inr(p.savings)}',
                                style: SwagTheme.body(
                                  size: 10.5,
                                  weight: FontWeight.w800,
                                  color: SwagColors.tangerineDeep,
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
      ('truck', 'Free shipping', 'On orders over ₹999', SwagColors.sky),
      ('shield', '7-day returns', 'No questions, no drama', SwagColors.pistachio),
      ('bolt', 'UPI & COD', 'Pay your way, safely', SwagColors.butter),
    ];
    return Row(
      children: [
        for (final (icon, title, sub, tint) in items)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: SwagColors.paper,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SwagColors.sand),
              ),
              child: Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SwagIcon(icon, size: 19, color: SwagColors.ink),
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

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.store, required this.copied, required this.onCopy});

  final SwagAppStore store;
  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SwagColors.tangerine, SwagColors.tangerineDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: SwagColors.tangerine.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SwagIcon('gift', size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'FIRST ORDER PERK',
                style: SwagTheme.body(
                  size: 11,
                  weight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Flat 15% off',
                style: SwagTheme.display(size: 28, color: Colors.white, height: 1.05),
              ),
              const SizedBox(width: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: Tween<double>(begin: 0.6, end: 1).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: copied
                    ? Container(
                        key: const ValueKey('copied'),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SwagIcon('check', size: 15, color: SwagColors.success),
                            const SizedBox(width: 5),
                            Text(
                              'Copied!',
                              style: SwagTheme.body(
                                size: 13,
                                weight: FontWeight.w800,
                                color: SwagColors.success,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        key: const ValueKey('code'),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Text(
                          'SWAG15',
                          style: SwagTheme.display(
                            size: 15,
                            weight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Applies at checkout on your very first order. No strings, only swag.',
            style: SwagTheme.body(size: 12, color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 14),
          Pressable(
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: SwagColors.cream,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwagIcon(
                    copied ? 'check' : 'copy',
                    size: 16,
                    color: copied ? SwagColors.success : SwagColors.ink,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    copied ? 'Code copied' : 'Copy code',
                    style: SwagTheme.display(
                      size: 14,
                      weight: FontWeight.w700,
                      color: SwagColors.ink,
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
