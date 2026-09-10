import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/swag_icon.dart';
import '../../state/app_store.dart';

/// Every product the user tapped the heart on.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SwagAppStore>();
    final saved = store.wishlistProducts;
    final pad = swagPad(MediaQuery.sizeOf(context).width);

    if (saved.isEmpty) {
      return EmptyState(
        image: 'assets/images/empty-heart.svg',
        title: 'Nothing saved yet',
        subtitle: 'Tap the heart on any product and it will show up right here.',
        actionLabel: 'Start exploring',
        onAction: () => store.requestTab(1),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 14, pad, 130),
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SwagColors.blushSoft,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SwagIcon('heart-filled', size: 19, color: SwagColors.blushDeep),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Wishlist',
                style: SwagTheme.display(size: 26),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: SwagColors.blushSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${saved.length} item${saved.length == 1 ? '' : 's'}',
                style: SwagTheme.body(
                  size: 12,
                  weight: FontWeight.w800,
                  color: SwagColors.blushDeep,
                ),
              ),
            ),
          ],
        )
            .animate().fadeIn(duration: 350.ms).moveY(begin: 12, end: 0, duration: 350.ms, curve: Curves.easeOut),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemCount: saved.length,
          itemBuilder: (context, i) => ProductCard(product: saved[i], stagger: i),
        ),
      ],
    );
  }
}
