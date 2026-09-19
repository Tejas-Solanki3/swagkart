// =============================================================================
// File: lib/features/wishlist/wishlist_screen.dart
// Purpose: Customer wishlist view displaying saved favorite items in a responsive
//          grid with instant add-to-bag capabilities and empty state fallbacks.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/swag_icon.dart';
import '../../core/widgets/swag_logo.dart';
import '../../data/models/product.dart';
import '../../state/app_store.dart';

/// Every product the user tapped the heart on.
///
/// If empty, renders [EmptyState] with an action navigating to the catalog.
/// Otherwise, presents saved items in an adaptive grid.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final store = context.watch<SwagAppStore>();
    final saved = store.wishlistProducts;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final pad = swagPad(screenWidth);

    if (saved.isEmpty) {
      return Scaffold(
        backgroundColor: SwagColors.canvas,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 14, pad, 0),
                child: const SwagLogo(size: 34, showText: true),
              ),
              Expanded(
                child: EmptyState(
                  image: 'assets/images/empty-heart.svg',
                  title: 'Nothing saved yet',
                  subtitle: 'Tap the heart on any product and it will show up right here.',
                  actionLabel: 'Start exploring',
                  onAction: () => store.requestTab(1),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isWeb = screenWidth >= 640;
    final cols = swagColumns(screenWidth - pad * 2);
    final rows = <List<Product>>[
      for (var i = 0; i < saved.length; i += cols)
        saved.sublist(i, i + cols > saved.length ? saved.length : i + cols),
    ];

    return Scaffold(
      backgroundColor: SwagColors.canvas,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: ListView(
            padding: EdgeInsets.fromLTRB(pad, 14, pad, 130),
            children: [
              FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SwagLogo(size: 34, showText: true),
                        const SizedBox(width: 14),
                        Container(width: 1, height: 22, color: SwagColors.line),
                        const SizedBox(width: 14),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: SwagColors.blushSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SwagIcon(
                              'heart-filled',
                              size: 17,
                              color: SwagColors.blushDeep,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('Wishlist', style: SwagTheme.display(size: 24)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: SwagColors.blushSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${saved.length} item${saved.length == 1 ? '' : 's'}',
                            style: SwagTheme.body(
                              size: 11.5,
                              weight: FontWeight.w800,
                              color: SwagColors.blushDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .moveY(
                    begin: 8,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 18),

              // Card Layout: Left-aligned Wrap on Web/Tablet, 2-column Grid on Phone
              if (isWeb)
                Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      for (var i = 0; i < saved.length; i++)
                        SizedBox(
                          width: 250,
                          child: ProductCard(product: saved[i], stagger: i),
                        ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    for (var r = 0; r < rows.length; r++)
                      Padding(
                        padding: EdgeInsets.only(top: r == 0 ? 0 : 14),
                        child: Row(
                          children: [
                            for (var c = 0; c < cols; c++) ...[
                              if (c > 0) const SizedBox(width: 14),
                              if (c < rows[r].length)
                                Expanded(
                                  child: ProductCard(
                                    product: rows[r][c],
                                    stagger: r * cols + c,
                                  ),
                                )
                              else
                                const Expanded(child: SizedBox.shrink()),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
