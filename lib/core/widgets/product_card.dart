// =============================================================================
// File: lib/core/widgets/product_card.dart
// Purpose: Grid and rail product card displaying image, brand, title, pricing,
//          discount pill, wishlist heart toggle, and instant add-to-bag action.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../data/models/product.dart';
import '../../features/product/product_detail_screen.dart';
import '../../state/app_store.dart';
import '../nav.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'emoji_celebration.dart';
import 'pressable.dart';
import 'swag_icon.dart';

/// Premium product card: white card, photo mat, heart bubble, quick "Shop" pill.
///
/// Tapping opens the [ProductDetailScreen]. Includes an interactive wishlist heart
/// and an inline cart addition button with spring animations.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.width,
    this.stagger = 0,
  });


  final Product product;
  final double? width;
  final int stagger;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SwagAppStore>();
    final wished = store.isWished(product.id);

    return Pressable(
          onTap: () => SwagNav.push(
            context,
            (context) => ProductDetailScreen(product: product),
          ),
          child: Container(
            width: width,
            decoration: SwagTheme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      decoration: BoxDecoration(
                        color: SwagColors.photoMat,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset(product.image, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    if (product.firstTag.isNotEmpty)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: _TagBadge(tag: product.firstTag),
                      ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: _HeartButton(
                        wished: wished,
                        onTap: () => store.toggleWishlist(product.id),
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 14,
                      child: _ShopPill(
                        onTap: () {
                          store.addToCart(
                            product,
                            product.sizes.first,
                            product.colors.isNotEmpty
                                ? product.colors.first
                                : 'Default',
                          );
                          fireCelebration(context);
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brand.toUpperCase(),
                        style: SwagTheme.body(
                          size: 10,
                          weight: FontWeight.w700,
                          color: SwagColors.inkFaint,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.name,
                        style: SwagTheme.display(
                          size: 14.5,
                          weight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const SwagIcon(
                            'star-filled',
                            size: 13,
                            color: SwagColors.butter,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: SwagTheme.body(
                              size: 11,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${compactCount(product.reviews)})',
                            style: SwagTheme.body(
                              size: 11,
                              color: SwagColors.inkFaint,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              inr(product.price),
                              style: SwagTheme.display(
                                size: 15.5,
                                weight: FontWeight.w800,
                                color: SwagColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.onSale) ...[
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                inr(product.mrp!),
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
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: SwagColors.green,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: SwagColors.butter.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🪙',
                                  style: TextStyle(fontSize: 9.5),
                                ),
                                const SizedBox(width: 2.5),
                                Text(
                                  '${product.swagPointsCost} pts',
                                  style: SwagTheme.body(
                                    size: 9.5,
                                    weight: FontWeight.w800,
                                    color: SwagColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: (stagger * 55).ms)
        .fadeIn(duration: 420.ms, curve: Curves.easeOut)
        .moveY(begin: 18, end: 0, duration: 420.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
          duration: 420.ms,
        );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.tag});

  final String tag;

  Color get _bg {
    switch (tag) {
      case 'trending':
        return SwagColors.accentSoft;
      case 'new':
        return SwagColors.mintSoft;
      case 'deal':
        return SwagColors.mistSoft;
      case 'winter':
        return SwagColors.lavenderSoft;
      case 'bestseller':
        return SwagColors.butterSoft;
      default:
        return SwagColors.surfaceMist;
    }
  }

  Color get _fg {
    switch (tag) {
      case 'trending':
        return SwagColors.accentDeep;
      case 'new':
        return SwagColors.mintDeep;
      case 'deal':
        return SwagColors.mistDeep;
      case 'winter':
        return SwagColors.lavenderDeep;
      case 'bestseller':
        return SwagColors.butterDeep;
      default:
        return SwagColors.inkSoft;
    }
  }

  String get _label {
    switch (tag) {
      case 'trending':
        return 'Hot';
      case 'new':
        return 'New';
      case 'deal':
        return 'Deal';
      case 'winter':
        return 'Winter';
      case 'bestseller':
        return 'Top pick';
      default:
        return tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag == 'trending') SwagIcon('fire', size: 11, color: _fg),
          Text(
            _label,
            style: SwagTheme.body(
              size: 11,
              weight: FontWeight.w700,
              color: _fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small black pill quick-add button over the product photo.
class _ShopPill extends StatelessWidget {
  const _ShopPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: SwagColors.ink,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: SwagColors.ink.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SwagIcon('bag', size: 13, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              'Shop',
              style: SwagTheme.body(
                size: 12,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartButton extends StatefulWidget {
  const _HeartButton({required this.wished, required this.onTap});

  final bool wished;
  final VoidCallback onTap;

  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton> {
  double _pop = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _pop = 1.45);
        Future<void>.delayed(const Duration(milliseconds: 140), () {
          if (mounted) setState(() => _pop = 0.92);
        });
        Future<void>.delayed(const Duration(milliseconds: 260), () {
          if (mounted) setState(() => _pop = 1);
        });
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pop,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: SwagColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: SwagColors.ink.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: SwagIcon(
              widget.wished ? 'heart-filled' : 'heart',
              size: 17,
              color: widget.wished ? SwagColors.accent : SwagColors.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}
