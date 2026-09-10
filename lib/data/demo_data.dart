import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'models/product.dart';

class SwagCategory {
  const SwagCategory(this.id, this.label, this.icon, this.tint);

  final String id;
  final String label;
  final String icon; // icon file name (no .svg)
  final Color tint;

  static const String allId = 'all';
}

class HeroSlide {
  const HeroSlide({
    required this.image,
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.accent,
  });

  final String image;
  final String kicker;
  final String title;
  final String subtitle;
  final String cta;
  final Color accent;
}

class Promo {
  const Promo({required this.code, required this.pct, required this.label});

  final String code;
  final double pct;
  final String label;
}

const List<SwagCategory> demoCategories = [
  SwagCategory(SwagCategory.allId, 'All', 'sparkles', SwagColors.accent),
  SwagCategory('streetwear', 'Streetwear', 'bolt', SwagColors.accent),
  SwagCategory('footwear', 'Footwear', 'fire', SwagColors.mist),
  SwagCategory('denim', 'Denim', 'tag', SwagColors.lavender),
  SwagCategory('accessories', 'Accessories', 'gift', SwagColors.mint),
  SwagCategory('winter', 'Winter', 'shield', SwagColors.blush),
];

// TODO(phase-1-assets): swap in lifestyle photography when it lands:
// assets/images/hero-street.png, hero-market.png, hero-sole.png.
// Until then the carousel uses studio product shots.
const List<HeroSlide> demoHeroes = [
  HeroSlide(
    image: 'assets/images/products/hoodie.png',
    kicker: 'New drop · SS26',
    title: 'Street fit, sorted in one tap',
    subtitle: 'Oversized fits, retro kicks & everyday staples.',
    cta: 'Shop the drop',
    accent: SwagColors.accent,
  ),
  HeroSlide(
    image: 'assets/images/products/court.png',
    kicker: 'Friends & family',
    title: 'Group swag, one bill',
    subtitle: 'Gift cards, free shipping over ₹999 and easy returns.',
    cta: 'Browse deals',
    accent: SwagColors.mint,
  ),
  HeroSlide(
    image: 'assets/images/products/runner.png',
    kicker: 'Sneaker vault',
    title: 'Fresh soles, fresh mood',
    subtitle: 'From court classics to chunky runners — all under ₹5K.',
    cta: 'Explore footwear',
    accent: SwagColors.mist,
  ),
];

const List<Promo> demoPromos = [
  Promo(code: 'SWAG15', pct: 15, label: '15% off your first order'),
  Promo(code: 'SWAG10', pct: 10, label: '10% off everything'),
];

const List<Product> demoProducts = [
  Product(
    id: 'p-hoodie',
    name: 'Cloud Nine Hoodie',
    brand: 'Mono Studio',
    category: 'streetwear',
    blurb:
        'Heavyweight 420 GSM loopback fleece with a relaxed drop-shoulder fit. '
        'Sweat-proof prints, pre-shrunk, zero pilling promises.',
    image: 'assets/images/products/hoodie.png',
    price: 2499,
    mrp: 3999,
    rating: 4.8,
    reviews: 412,
    colors: ['#FF6B35', '#F8F3EA', '#221A13'],
    sizes: ['S', 'M', 'L', 'XL', 'XXL'],
    tags: ['trending', 'bestseller'],
    stock: 24,
  ),
  Product(
    id: 'p-runner',
    name: 'Rangoli Runner',
    brand: 'Sole Society',
    category: 'footwear',
    blurb:
        'A retro court runner on a cushioned gum sole. Breathable knit upper, '
        'hand-washable, and built for 10K steps a day.',
    image: 'assets/images/products/runner.png',
    price: 4299,
    mrp: 5499,
    rating: 4.7,
    reviews: 288,
    colors: ['#F1E9DA', '#FFD166'],
    sizes: ['UK 6', 'UK 7', 'UK 8', 'UK 9', 'UK 10'],
    tags: ['trending'],
    stock: 18,
  ),
  Product(
    id: 'p-bomber',
    name: 'Bazaar Bomber',
    brand: 'Chak & Co',
    category: 'streetwear',
    blurb:
        'Water-repellent shell with a brushed lining, ribbed cuffs and two-way zip. '
        'Cuts clean over tees and hoodies alike.',
    image: 'assets/images/products/bomber.png',
    price: 5999,
    mrp: 7999,
    rating: 4.6,
    reviews: 173,
    colors: ['#6B7F5E', '#221A13'],
    sizes: ['S', 'M', 'L', 'XL'],
    tags: ['new'],
    stock: 15,
  ),
  Product(
    id: 'p-court',
    name: 'Minty Court',
    brand: 'Sole Society',
    category: 'footwear',
    blurb:
        'Low-top court sneaker in pistachio nubuck. Clean lines, chunky white cupsole, '
        'and a heel tab you will love.',
    image: 'assets/images/products/court.png',
    price: 3799,
    mrp: 4599,
    rating: 4.5,
    reviews: 231,
    colors: ['#8FCF9B', '#F8F3EA'],
    sizes: ['UK 6', 'UK 7', 'UK 8', 'UK 9'],
    tags: ['deal'],
    stock: 22,
  ),
  Product(
    id: 'p-jeans',
    name: 'Jaali Wide Jeans',
    brand: 'Desi Denim',
    category: 'denim',
    blurb:
        'Light-wash wide legs with a high rise and soft stretch. Garment-washed for '
        'that broken-in feel from day one.',
    image: 'assets/images/products/jeans.png',
    price: 3299,
    mrp: 4199,
    rating: 4.7,
    reviews: 356,
    colors: ['#9DB8D9', '#221A13'],
    sizes: ['28', '30', '32', '34', '36'],
    tags: ['bestseller'],
    stock: 30,
  ),
  Product(
    id: 'p-tee',
    name: 'Sunday Sun Tee',
    brand: 'Mono Studio',
    category: 'streetwear',
    blurb:
        'Boxy-fit 240 GSM combed cotton tee with a hand-drawn sun print. '
        'Garment-dyed, slightly vintage, very easy to live in.',
    image: 'assets/images/products/tee.png',
    price: 1199,
    mrp: 1799,
    rating: 4.4,
    reviews: 198,
    colors: ['#F1E9DA', '#FFD166'],
    sizes: ['S', 'M', 'L', 'XL'],
    tags: ['new'],
    stock: 40,
  ),
  Product(
    id: 'p-tote',
    name: 'Bazaar Tote',
    brand: 'Craft & Co',
    category: 'accessories',
    blurb:
        'Heavy 16oz canvas tote that swallows a laptop, gym kit and a dozen samosas. '
        'Reinforced handles, inner zip pocket.',
    image: 'assets/images/products/tote.png',
    price: 999,
    rating: 4.6,
    reviews: 521,
    colors: ['#D8C7A7'],
    sizes: ['One size'],
    tags: ['bestseller'],
    stock: 60,
  ),
  Product(
    id: 'p-cap',
    name: 'Six-Panel Spark Cap',
    brand: 'Chak & Co',
    category: 'accessories',
    blurb:
        'Structured six-panel in washed cotton twill with a tonal spark embroidery. '
        'Adjustable brass buckle back.',
    image: 'assets/images/products/cap.png',
    price: 899,
    mrp: 1299,
    rating: 4.3,
    reviews: 142,
    colors: ['#D8C7A7', '#221A13'],
    sizes: ['One size'],
    tags: ['deal'],
    stock: 35,
  ),
  Product(
    id: 'p-shades',
    name: 'Retro Round Shades',
    brand: 'Craft & Co',
    category: 'accessories',
    blurb:
        'Round tortoise frames with thin gold hardware and UV400 lenses. '
        'Comes with a hard case and microfibre cloth.',
    image: 'assets/images/products/shades.png',
    price: 1499,
    rating: 4.5,
    reviews: 88,
    colors: ['#5B4632'],
    sizes: ['One size'],
    tags: ['new'],
    stock: 20,
  ),
  Product(
    id: 'p-boots',
    name: 'Metro Chelsea Boots',
    brand: 'Sole Society',
    category: 'footwear',
    blurb:
        'Pull-on Chelsea in full-grain leather with elastic side gores and a stacked '
        'rubber heel. Pairs with everything.',
    image: 'assets/images/products/boots.png',
    price: 6499,
    mrp: 8999,
    rating: 4.8,
    reviews: 164,
    colors: ['#221A13'],
    sizes: ['UK 6', 'UK 7', 'UK 8', 'UK 9', 'UK 10'],
    tags: ['winter', 'trending'],
    stock: 12,
  ),
  Product(
    id: 'p-beanie',
    name: 'Cozy Cloud Beanie',
    brand: 'Craft & Co',
    category: 'winter',
    blurb:
        'Chunky-knit ribbed beanie in soft acrylic-wool blend. One size, lots of coziness.',
    // TODO(phase-1-assets): swap in assets/images/products/beanie.png when generated.
    image: 'assets/images/products/cap.png',
    price: 799,
    mrp: 999,
    rating: 4.4,
    reviews: 76,
    colors: ['#F1E9DA', '#FF6B35'],
    sizes: ['One size'],
    tags: ['winter', 'deal'],
    stock: 28,
  ),
  Product(
    id: 'p-pack',
    name: 'Pillow Pack 22L',
    brand: 'Craft & Co',
    category: 'accessories',
    blurb:
        'Padded 22L backpack in recycled nylon. Laptop sleeve, bottle pocket, '
        'and a rain cover tucked inside.',
    // TODO(phase-1-assets): swap in assets/images/products/pack.png when generated.
    image: 'assets/images/products/tote.png',
    price: 2999,
    mrp: 3999,
    rating: 4.6,
    reviews: 209,
    colors: ['#9CAF88'],
    sizes: ['One size'],
    tags: ['trending'],
    stock: 25,
  ),
];
