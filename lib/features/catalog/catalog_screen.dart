// =============================================================================
// File: lib/features/catalog/catalog_screen.dart
// Purpose: Product catalog explorer featuring category filtering pills, sorting
//          options (popular, price, rating), search query filtering, and responsive grid layout.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/chip.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/swag_icon.dart';
import '../../core/widgets/swag_logo.dart';
import '../../data/demo_data.dart';
import '../../data/models/product.dart';
import '../../state/app_store.dart';

/// Full product collection browser.
///
/// Features:
/// - Horizontal category filter pills with active state
/// - Sort modal bottom sheet (popularity, lowest price, highest price, customer rating)
/// - Inline live search query filtering
/// - Responsive grid rendering 2 to 4 columns depending on viewport width
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});


  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _category = SwagCategory.allId;
  SortMode _sort = SortMode.popular;
  String _query = '';
  bool _loading = false;
  int _gridKey = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyPending();
  }

  /// Picks up category requests coming from other tabs (home, hero, etc.).
  void _applyPending() {
    final store = context.read<SwagAppStore>();
    final pending = store.pendingCategory;
    if (pending != null && pending != 'deals') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _category = pending);
        store.consumeTabRequest();
      });
    } else if (pending == 'deals') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _category = SwagCategory.allId;
            _query = '';
          });
        }
        store.consumeTabRequest();
      });
    }
  }

  void _changeCategory(String id) {
    setState(() {
      _category = id;
      _gridKey++;
    });
    _simulateLoad();
  }

  void _changeSort(SortMode mode) {
    setState(() {
      _sort = mode;
      _gridKey++;
    });
  }

  void _simulateLoad() {
    setState(() => _loading = true);
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  List<Product> _results(SwagAppStore store) {
    List<Product> list = store.byCategory(_category, sort: _sort);
    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      list = list
          .where(
            (p) =>
                '${p.name} ${p.brand} ${p.category} ${p.blurb} ${p.tags.join(' ')}'
                    .toLowerCase()
                    .contains(q),
          )
          .toList();
    }
    if (_category == 'deals' || _query == 'deals') {
      list = list.where((p) => p.onSale).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SwagAppStore>(
      builder: (context, store, _) {
        _applyPending();
        final results = _results(store);
        final pad = swagPad(MediaQuery.sizeOf(context).width);
        return ListView(
          padding: EdgeInsets.fromLTRB(pad, 14, pad, 130),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SwagLogo(size: 34, showText: true),
                const SizedBox(width: 12),
                Container(width: 1, height: 22, color: SwagColors.line),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('The Catalog', style: SwagTheme.display(size: 22)),
                      const SizedBox(height: 2),
                      Text(
                        'Every piece, one tap away',
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
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: SwagColors.surfaceMist,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${results.length} items',
                    style: SwagTheme.body(
                      size: 12,
                      weight: FontWeight.w800,
                      color: SwagColors.inkSoft,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Search field
            Container(
              height: 52,
              decoration: SwagTheme.cardDecoration(radius: 999),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const SwagIcon('search', size: 19, color: SwagColors.inkSoft),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: SwagTheme.body(size: 14),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search this catalog…',
                        hintStyle: TextStyle(
                          color: SwagColors.inkFaint,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    Pressable(
                      onTap: () => setState(() => _query = ''),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: SwagIcon(
                          'close',
                          size: 16,
                          color: SwagColors.inkSoft,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Category chips
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: store.categories.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  if (i == store.categories.length) {
                    return SwagChip(
                      label: 'On Sale',
                      icon: 'tag',
                      selected: _category == 'deals' || _query == 'deals',
                      activeColor: SwagColors.ink,
                      onTap: () {
                        setState(() {
                          _query = _query == 'deals' ? '' : 'deals';
                          _gridKey++;
                        });
                        _simulateLoad();
                      },
                    );
                  }
                  final cat = store.categories[i];
                  return SwagChip(
                    label: cat.label,
                    icon: cat.icon,
                    selected: _category == cat.id && _query != 'deals',
                    activeColor: SwagColors.ink,
                    onTap: () => _changeCategory(cat.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            // Sort chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    'Sort',
                    style: SwagTheme.body(
                      size: 12,
                      weight: FontWeight.w800,
                      color: SwagColors.inkSoft,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ...[
                    (SortMode.popular, 'Popular'),
                    (SortMode.priceLowHigh, 'Price ↑'),
                    (SortMode.priceHighLow, 'Price ↓'),
                    (SortMode.rating, 'Top rated'),
                  ].map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SwagChip(
                        label: e.$2,
                        fontSize: 12,
                        selected: _sort == e.$1,
                        activeColor: SwagColors.ink,
                        onTap: () => _changeSort(e.$1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_loading)
              _SkeletonGrid()
            else if (results.isEmpty)
              EmptyState(
                image: 'assets/images/empty-bag.svg',
                title: 'Nothing swagged here',
                subtitle: 'No matches for your filters. Loosen up a little and try again.',
                actionLabel: 'Show everything',
                onAction: () => setState(() {
                  _category = SwagCategory.allId;
                  _query = '';
                  _gridKey++;
                }),
              )
            else
              _ProductGrid(products: results, cols: _gridKey),
          ],
        );
      },
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products, required this.cols});

  final List<Product> products;
  final int cols;

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.sizeOf(context).width -
        swagPad(MediaQuery.sizeOf(context).width) * 2;
    final columnCount = swagColumns(width);
    final rows = <List<Product>>[
      for (var i = 0; i < products.length; i += columnCount)
        products.sublist(
          i,
          i + columnCount > products.length ? products.length : i + columnCount,
        ),
    ];
    return KeyedSubtree(
      key: ValueKey(cols),
      child:
          Column(
                children: [
                  for (var r = 0; r < rows.length; r++)
                    Padding(
                      padding: EdgeInsets.only(top: r == 0 ? 0 : 14),
                      child: Row(
                        children: [
                          for (var c = 0; c < rows[r].length; c++) ...[
                            if (c > 0) const SizedBox(width: 14),
                            Expanded(
                              child: ProductCard(
                                product: rows[r][c],
                                stagger: r * columnCount + c,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .moveY(begin: 10, end: 0, duration: 300.ms),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.sizeOf(context).width -
        swagPad(MediaQuery.sizeOf(context).width) * 2;
    final columnCount = swagColumns(width);
    return Column(
      children: [
        for (var r = 0; r < 2; r++)
          Padding(
            padding: EdgeInsets.only(top: r == 0 ? 0 : 14),
            child: Row(
              children: [
                for (var c = 0; c < columnCount; c++) ...[
                  if (c > 0) const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 270,
                      child: const ShimmerBox(radius: 24),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
