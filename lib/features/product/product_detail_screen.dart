import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/emoji_celebration.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/swag_button.dart';
import '../../core/widgets/swag_icon.dart';
import '../../data/models/product.dart';
import '../../state/app_store.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  final PageController _gallery = PageController();
  int _galleryPage = 0;
  String? _size;
  int _colorIndex = 0;
  int _qty = 1;
  bool _added = false;
  bool _fabricOpen = true;
  bool _careOpen = false;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.length == 1) {
      _size = widget.product.sizes.first;
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    _gallery.dispose();
    super.dispose();
  }

  void _pickSize(String s) => setState(() => _size = s);

  void _addToBag({bool buyNow = false}) {
    final store = context.read<SwagAppStore>();
    if (_size == null) {
      _shake.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SwagIcon('bolt', size: 16, color: SwagColors.accent),
              SizedBox(width: 8),
              Expanded(
                child: Text('Pick a size first, swag head!'),
              ),
            ],
          ),
        ),
      );
      return;
    }
    final color = widget.product.colors.isNotEmpty
        ? widget.product.colors[_colorIndex]
        : 'Default';
    store.addToCart(widget.product, _size!, color, qty: _qty);
    fireCelebration(context);
    setState(() => _added = true);
    if (buyNow) {
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        store.requestTab(3);
        SwagNav.popToRoot(context);
      });
      return;
    }
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.product.name} added to your bag',
            style: SwagTheme.body(
              size: 13,
              weight: FontWeight.w700,
              color: SwagColors.canvas,
            ),
          ),
          action: SnackBarAction(
            label: 'View bag',
            textColor: SwagColors.accent,
            onPressed: () {
              store.requestTab(3);
              SwagNav.popToRoot(context);
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final wished = context.watch<SwagAppStore>().isWished(product.id);
    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < 640;

    return Scaffold(
      backgroundColor: SwagColors.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      _RoundButton(icon: 'arrow-left', onTap: () => SwagNav.pop(context)),
                      const Spacer(),
                      Text('Details', style: SwagTheme.display(size: 18)),
                      const Spacer(),
                      _RoundButton(
                        icon: wished ? 'heart-filled' : 'heart',
                        colored: wished,
                        onTap: () => context.read<SwagAppStore>().toggleWishlist(product.id),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      isPhone ? 16 : 24,
                      0,
                      isPhone ? 16 : 24,
                      120,
                    ),
                    children: [
                      _Gallery(
                        images: product.allImages,
                        controller: _gallery,
                        page: _galleryPage,
                        onPageChanged: (p) => setState(() => _galleryPage = p),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: SwagColors.lavenderSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              product.brand,
                              style: SwagTheme.body(
                                size: 11,
                                weight: FontWeight.w800,
                                color: SwagColors.ink,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const SwagIcon('star-filled', size: 16, color: SwagColors.butter),
                              const SizedBox(width: 4),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: SwagTheme.body(size: 13, weight: FontWeight.w800),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '· ${product.reviews} reviews',
                                style: SwagTheme.body(size: 12, color: SwagColors.inkSoft),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.name,
                        style: SwagTheme.display(size: 27, height: 1.1),
                      ),
                      const SizedBox(height: 14),
                      _PriceCard(product: product),
                      const SizedBox(height: 16),
                      if (product.colors.isNotEmpty) ...[
                        _OptionRow(
                          label: 'Colour',
                          value: _colorName(product, _colorIndex),
                          children: Row(
                            children: [
                              for (var i = 0; i < product.colors.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _ColorDot(
                                    hex: product.colors[i],
                                    selected: i == _colorIndex,
                                    onTap: () => setState(() {
                                      _colorIndex = i;
                                      // For products whose gallery IS the
                                      // color lineup (hoodie, runner),
                                      // jump the photo to the picked color.
                                      final imgs = product.allImages;
                                      if (imgs.length > 1 &&
                                          imgs.length == product.colors.length) {
                                        _gallery.animateToPage(
                                          i,
                                          duration: const Duration(milliseconds: 420),
                                          curve: Curves.easeOut,
                                        );
                                      }
                                    }),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      AnimatedBuilder(
                        animation: _shake,
                        builder: (context, child) {
                          final t = _shake.value;
                          final angle = t <= 0 || t >= 1
                              ? 0.0
                              : (math.sin(t * math.pi * 5) * 0.05 * (1 - t));
                          return Transform.rotate(angle: angle, child: child);
                        },
                        child: _OptionRow(
                          label: 'Size',
                          value: _size ?? '—',
                          children: Row(
                            children: [
                              for (final s in product.sizes)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _SizeChip(
                                    label: s,
                                    selected: s == _size,
                                    onTap: () => _pickSize(s),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _QtyRow(
                        qty: _qty,
                        onChanged: (q) => setState(() => _qty = q),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        product.blurb,
                        style: SwagTheme.body(size: 13.5, color: SwagColors.inkSoft),
                      ),
                      const SizedBox(height: 16),
                      _AccordionCard(
                        icon: 'tag',
                        title: 'Fabric & fit',
                        open: _fabricOpen,
                        onToggle: () => setState(() => _fabricOpen = !_fabricOpen),
                        child: const Text(
                          'Cut generously for a relaxed drop-shoulder silhouette. '
                          'Model is 5’11” and wears a size M. True to size — '
                          'size down if you like it fitted.',
                          style: TextStyle(fontSize: 12.5, color: SwagColors.inkSoft, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _AccordionCard(
                        icon: 'shield',
                        title: 'Care & shipping',
                        open: _careOpen,
                        onToggle: () => setState(() => _careOpen = !_careOpen),
                        child: const Text(
                          'Machine wash cold, hang dry. Free standard delivery in '
                          '4–6 days on orders over ₹999, express in 1–2 days. '
                          '7-day no-questions returns with doorstep pickup.',
                          style: TextStyle(fontSize: 12.5, color: SwagColors.inkSoft, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          for (final (icon, tint, label) in [
                            ('truck', SwagColors.mist, 'Free ship over ₹999'),
                            ('shield', SwagColors.mint, '7-day returns'),
                            ('bolt', SwagColors.butter, 'UPI · COD · EMI'),
                          ])
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: tint.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  children: [
                                    SwagIcon(icon, size: 18, color: SwagColors.ink),
                                    const SizedBox(height: 5),
                                    Text(
                                      label,
                                      style: SwagTheme.body(size: 10, weight: FontWeight.w700),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      const SectionHeader(title: 'Goes well with'),
                      SizedBox(
                        height: 268,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final store = context.read<SwagAppStore>();
                            final related = store.relatedTo(product);
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: related.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 12),
                              itemBuilder: (context, i) =>
                                  ProductCard(product: related[i], width: 172, stagger: i),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Sticky bottom bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  isPhone ? 16 : 24,
                  12,
                  isPhone ? 16 : 24,
                  16,
                ),
                decoration: const BoxDecoration(
                  color: SwagColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x10585470),
                      blurRadius: 18,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Pressable(
                      onTap: () {
                        final store = context.read<SwagAppStore>();
                        store.requestTab(0);
                        SwagNav.popToRoot(context);
                      },
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: SwagColors.surfaceMist,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SwagIcon(
                            'home',
                            size: 22,
                            color: SwagColors.ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => ScaleTransition(
                          scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
                          child: FadeTransition(opacity: animation, child: child),
                        ),
                        child: SwagButton(
                          key: ValueKey(_added ? 'added' : 'add'),
                          label: _added ? 'Added to bag ✓' : 'Buy Now',
                          trailingIcon: _added ? null : 'arrow-right',
                          background: _added ? SwagColors.success : SwagColors.ink,
                          shine: !_added,
                          icon: _added ? 'check' : 'bag',
                          onTap: () => _addToBag(buyNow: !_added),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _colorName(Product product, int index) {
    final colors = {
      '#FF6B35': 'Tangerine',
      '#F8F3EA': 'Cream',
      '#221A13': 'Ink',
      '#FFD166': 'Butter',
      '#8FCF9B': 'Pistachio',
      '#9DB8D9': 'Washed Blue',
      '#6B7F5E': 'Olive',
      '#D8C7A7': 'Sand',
      '#5B4632': 'Tortoise',
      '#9CAF88': 'Sage',
      '#F1E9DA': 'Oat',
    };
    return colors[product.colors[index]] ?? 'Default';
  }
}

// ---------------------------------------------------------------------------

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onTap, this.colored = false});

  final String icon;
  final VoidCallback? onTap;
  final bool colored;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: SwagTheme.iconButtonDecoration(),
        child: Center(
          child: SwagIcon(
            icon,
            size: 19,
            color: colored ? SwagColors.accent : SwagColors.ink,
          ),
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.images,
    required this.controller,
    required this.page,
    required this.onPageChanged,
  });

  final List<String> images;
  final PageController controller;
  final int page;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gallery = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: SwagColors.photoMat,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: SwagColors.line),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: images.length,
            itemBuilder: (context, i) =>
                Image.asset(images[i], fit: BoxFit.cover),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? SwagColors.ink : SwagColors.ink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
    return width < 640
        ? AspectRatio(aspectRatio: 1, child: gallery)
        : Center(child: SizedBox(width: 460, height: 460, child: gallery));
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwagColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SwagColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                inr(product.price),
                style: SwagTheme.display(size: 30, weight: FontWeight.w800),
              ),
              if (product.onSale) ...[
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    inr(product.mrp!),
                    style: SwagTheme.body(
                      size: 15,
                      color: SwagColors.inkFaint,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: SwagColors.butterSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Save ${product.discountPct}%',
                      style: SwagTheme.body(
                        size: 11,
                        weight: FontWeight.w800,
                        color: SwagColors.butterDeep,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SwagIcon('shield', size: 14, color: SwagColors.success),
              const SizedBox(width: 6),
              Text(
                'Inclusive of all taxes (GST) · Free delivery over ₹999',
                style: SwagTheme.body(size: 11.5, color: SwagColors.inkSoft),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.value,
    required this.children,
  });

  final String label;
  final String value;
  final Widget children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SwagColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SwagColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: SwagTheme.body(size: 12, weight: FontWeight.w800, color: SwagColors.inkSoft),
              ),
              const Spacer(),
              Text(
                value,
                style: SwagTheme.body(size: 12, weight: FontWeight.w700, color: SwagColors.inkFaint),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: children,
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.hex, required this.selected, required this.onTap});

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  Color get _color => Color(int.parse(hex.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _color,
          border: Border.all(
            color: selected ? SwagColors.ink : SwagColors.line,
            width: selected ? 2.4 : 1.4,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: SwagColors.ink.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: selected
            ? const Center(child: SwagIcon('check', size: 16, color: Colors.white))
            : null,
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isWide = label.length > 3;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: isWide ? 58 : 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected ? SwagColors.ink : SwagColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? SwagColors.ink : SwagColors.line,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: SwagTheme.body(
              size: 13,
              weight: FontWeight.w800,
              color: selected ? SwagColors.canvas : SwagColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyRow extends StatelessWidget {
  const _QtyRow({required this.qty, required this.onChanged});

  final int qty;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Quantity',
          style: SwagTheme.body(size: 12, weight: FontWeight.w800, color: SwagColors.inkSoft),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: SwagColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SwagColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepButton(icon: 'minus', disabled: qty <= 1, onTap: () => onChanged(qty - 1)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: Tween<double>(begin: 0.5, end: 1).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Text(
                  '$qty',
                  key: ValueKey(qty),
                  style: SwagTheme.display(size: 16, weight: FontWeight.w800),
                ),
              ),
              _StepButton(icon: 'plus', onTap: () => onChanged(qty + 1)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap, this.disabled = false});

  final String icon;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: disabled ? SwagColors.surfaceMist : SwagColors.canvas,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SwagIcon(
            icon,
            size: 16,
            color: disabled ? SwagColors.inkFaint : SwagColors.ink,
          ),
        ),
      ),
    );
  }
}

class _AccordionCard extends StatelessWidget {
  const _AccordionCard({
    required this.icon,
    required this.title,
    required this.open,
    required this.onToggle,
    required this.child,
  });

  final String icon;
  final String title;
  final bool open;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SwagColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SwagColors.line),
      ),
      child: Column(
        children: [
          Pressable(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: SwagColors.surfaceMist,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SwagIcon(icon, size: 17, color: SwagColors.ink),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: SwagTheme.body(size: 14, weight: FontWeight.w800),
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    child: const SwagIcon('chevron-down', size: 18, color: SwagColors.inkSoft),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
