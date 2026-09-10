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
import 'pressable.dart';
import 'swag_icon.dart';

/// Responsive product card used across home, catalog, search and related rows.
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
        decoration: BoxDecoration(
          color: SwagColors.paper,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: SwagColors.sand),
          boxShadow: [
            BoxShadow(
              color: SwagColors.ink.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  decoration: BoxDecoration(
                    color: SwagColors.sandSoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(product.image, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
                if (product.firstTag.isNotEmpty)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: _TagBadge(tag: product.firstTag),
                  ),
                if (product.onSale)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: SwagColors.butter,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '-${product.discountPct}%',
                        style: SwagTheme.body(
                          size: 11,
                          weight: FontWeight.w700,
                          color: SwagColors.ink,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: _HeartButton(
                    wished: wished,
                    onTap: () => store.toggleWishlist(product.id),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 10, 13, 13),
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
                  const SizedBox(height: 3),
                  Text(
                    product.name,
                    style: SwagTheme.display(size: 15, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SwagIcon('star-filled', size: 13, color: SwagColors.butter),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: SwagTheme.body(size: 11, weight: FontWeight.w700),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${compactCount(product.reviews)})',
                        style: SwagTheme.body(size: 11, color: SwagColors.inkFaint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          inr(product.price),
                          style: SwagTheme.display(
                            size: 16,
                            weight: FontWeight.w800,
                            color: SwagColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.onSale) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 1.5),
                            child: Text(
                              inr(product.mrp!),
                              style: SwagTheme.body(
                                size: 11,
                                color: SwagColors.inkFaint,
                                decoration: TextDecoration.lineThrough,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(
      delay: (stagger * 55).ms,
    ).fadeIn(duration: 420.ms, curve: Curves.easeOut).moveY(begin: 18, end: 0, duration: 420.ms, curve: Curves.easeOut).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1), duration: 420.ms);
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.tag});

  final String tag;

  Color get _bg {
    switch (tag) {
      case 'trending':
        return SwagColors.tangerine;
      case 'new':
        return SwagColors.pistachio;
      case 'deal':
        return SwagColors.sky;
      case 'winter':
        return SwagColors.lilac;
      case 'bestseller':
        return SwagColors.butter;
      default:
        return SwagColors.sand;
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
          if (tag == 'trending')
            const SwagIcon('fire', size: 11, color: Colors.white),
          Text(
            _label,
            style: SwagTheme.body(
              size: 11,
              weight: FontWeight.w700,
              color: tag == 'new' || tag == 'deal' ? SwagColors.ink : Colors.white,
            ),
          ),
        ],
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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: SwagColors.paper,
            shape: BoxShape.circle,
            border: Border.all(color: SwagColors.sand),
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
              color: widget.wished ? SwagColors.tangerine : SwagColors.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}
