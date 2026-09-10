import 'package:flutter/foundation.dart';

import '../core/theme/app_colors.dart';
import '../data/demo_data.dart';
import '../data/models/cart_item.dart';
import '../data/models/product.dart';

enum SortMode { popular, priceLowHigh, priceHighLow, rating }

/// Shared in-memory demo state for the whole SwagKart app.
///
/// Phase 1 keeps everything in memory so the demo runs offline;
/// Phase 2+ will swap the data sources for network + persistence
/// without touching the widget tree.
class SwagAppStore extends ChangeNotifier {
  // ------------------------------------------------------------------ data
  final List<Product> products = demoProducts;
  final List<SwagCategory> categories = demoCategories;
  final List<HeroSlide> heroes = demoHeroes;
  final List<Promo> promos = demoPromos;
  final List<String> recentSearches = const [
    'oversized hoodie',
    'retro runners',
    'canvas tote',
    'chelsea boots',
  ];
  final List<String> trendingTags = const [
    'hoodies',
    'sneakers',
    'denim',
    'totes',
    'beanies',
    'shades',
  ];

  // ------------------------------------------------------------- cart
  final List<CartItem> cart = [];
  Promo? appliedPromo;

  // ---------------------------------------------------------- wishlist
  final Set<String> wishlist = {};

  // ------------------------------------------------------ tab requests
  /// Bumped every time a feature wants the shell to switch tabs.
  int tabToken = 0;
  int? tabTarget;
  String? pendingCategory;
  int cartPulse = 0;

  void requestTab(int index, {String? category}) {
    tabToken++;
    tabTarget = index;
    pendingCategory = category;
    notifyListeners();
  }

  void consumeTabRequest() {
    tabTarget = null;
    pendingCategory = null;
    notifyListeners();
  }

  // ------------------------------------------------------------- cart ops
  int get cartCount => cart.fold(0, (sum, i) => sum + i.qty);
  double get subtotal => cart.fold(0.0, (sum, i) => sum + i.lineTotal);
  double get discountAmount =>
      appliedPromo == null ? 0.0 : subtotal * appliedPromo!.pct / 100;
  double get afterDiscount => subtotal - discountAmount;
  bool get qualifiesFreeShipping => afterDiscount >= kFreeShippingThreshold;
  double get shippingFee =>
      cart.isEmpty ? 0.0 : (qualifiesFreeShipping ? 0.0 : 79);
  double get total => afterDiscount + shippingFee;
  double get savings =>
      discountAmount + (cart.isNotEmpty && qualifiesFreeShipping ? 79.0 : 0.0);

  void addToCart(Product product, String size, String color, {int qty = 1}) {
    final key = CartItem.keyFor(product.id, size, color);
    for (final item in cart) {
      if (item.key == key) {
        item.qty += qty;
        _pulse();
        return;
      }
    }
    cart.add(CartItem(product: product, size: size, color: color, qty: qty));
    _pulse();
  }

  void setQty(CartItem item, int qty) {
    if (qty <= 0) {
      removeItem(item);
      return;
    }
    item.qty = qty;
    notifyListeners();
  }

  void removeItem(CartItem item) {
    cart.remove(item);
    if (cart.isEmpty) appliedPromo = null;
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    appliedPromo = null;
    notifyListeners();
  }

  /// Public helper for undoing a clear.
  void restoreCart(List<CartItem> items) {
    cart
      ..clear()
      ..addAll(items);
    if (cart.isEmpty) appliedPromo = null;
    notifyListeners();
  }

  bool applyPromo(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return false;
    Promo? match;
    for (final p in promos) {
      if (p.code == normalized) {
        match = p;
        break;
      }
    }
    if (match == null) return false;
    appliedPromo = match;
    notifyListeners();
    return true;
  }

  void clearPromo() {
    appliedPromo = null;
    notifyListeners();
  }

  // ------------------------------------------------------------ wishlist
  bool isWished(String id) => wishlist.contains(id);

  void toggleWishlist(String id) {
    if (!wishlist.add(id)) {
      wishlist.remove(id);
    }
    notifyListeners();
  }

  List<Product> get wishlistProducts =>
      products.where((p) => wishlist.contains(p.id)).toList();

  // ------------------------------------------------------------ discovery
  List<Product> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.of(products);
    return products.where((p) {
      final haystack = [
        p.name,
        p.brand,
        p.category,
        p.blurb,
        ...p.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  List<Product> byCategory(String categoryId, {SortMode sort = SortMode.popular}) {
    List<Product> list;
    if (categoryId == SwagCategory.allId) {
      list = List.of(products);
    } else {
      list = products.where((p) => p.category == categoryId).toList();
    }
    switch (sort) {
      case SortMode.popular:
        list.sort((a, b) => b.reviews.compareTo(a.reviews));
      case SortMode.priceLowHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortMode.priceHighLow:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortMode.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  List<Product> relatedTo(Product product, {int limit = 4}) {
    final list = products
        .where((p) => p.id != product.id && p.category == product.category)
        .toList();
    final rest = products
        .where((p) => p.id != product.id && p.category != product.category)
        .toList();
    return [...list, ...rest].take(limit).toList();
  }

  void _pulse() {
    cartPulse++;
    notifyListeners();
  }
}
