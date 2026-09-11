import 'package:flutter/foundation.dart';

import '../data/demo_data.dart';
import '../data/models/cart_item.dart';
import '../data/models/order.dart';
import '../data/models/product.dart';

const double kFreeShippingThreshold = 999;
const double kFlatShippingFee = 79;

/// Catalog sort options (catalog rail + home rails).
enum SortMode { popular, priceLowHigh, priceHighLow, rating }

class SwagAppStore extends ChangeNotifier {
  // ------------------------------------------------------------- catalog
  final List<Product> products = demoProducts;
  Product? _selected;

  Product? get selected => _selected;

  void select(Product p) {
    if (identical(_selected, p)) return;
    _selected = p;
    notifyListeners();
  }

  /// Category rail data + cross-tab navigation requests.
  List<SwagCategory> get categories => demoCategories;

  int? tabTarget;
  String? pendingCategory;

  /// Ask the shell to switch tabs (optionally with a catalog category).
  void requestTab(int index, {String? category}) {
    tabTarget = index;
    pendingCategory = category;
    notifyListeners();
  }

  /// Shell/catalog acknowledge a request was consumed.
  void consumeTabRequest() {
    tabTarget = null;
    pendingCategory = null;
    notifyListeners();
  }

  List<Product> byCategory(String category, {SortMode sort = SortMode.popular}) {
    final list = category == SwagCategory.allId
        ? List.of(products)
        : products.where((p) => p.category == category).toList();
    switch (sort) {
      case SortMode.priceLowHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortMode.priceHighLow:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortMode.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case SortMode.popular:
        list.sort((a, b) => b.reviews.compareTo(a.reviews));
    }
    return list;
  }

  // ------------------------------------------------------------- cart
  final List<CartItem> cart = [];
  Promo? appliedPromo;
  SwagOrder? lastOrder;

  int get cartCount => cart.fold(0, (sum, i) => sum + i.qty);

  double get subtotal => cart.fold(0.0, (sum, i) => sum + i.lineTotal);

  double get discountAmount => appliedPromo == null
      ? 0.0
      : subtotal * appliedPromo!.pct / 100;

  double get afterDiscount => subtotal - discountAmount;

  /// What the shopper actually saves: promo + waived shipping.
  double get savings => discountAmount +
      (cart.isNotEmpty && qualifiesFreeShipping ? kFlatShippingFee : 0.0);

  bool get qualifiesFreeShipping => afterDiscount >= kFreeShippingThreshold;

  double get shippingFee =>
      cart.isEmpty || qualifiesFreeShipping ? 0.0 : kFlatShippingFee;

  double get total => afterDiscount + shippingFee;

  // ------------------------------------------------------------- wishlist
  final Set<String> wishlist = {};

  int get wishlistCount => wishlist.length;

  void addToCart(Product product, String size, String color, {int qty = 1}) {
    final key = CartItem.keyFor(product.id, size, color);
    final i = cart.indexWhere((c) => c.key == key);
    if (i == -1) {
      cart.add(CartItem(product: product, size: size, color: color, qty: qty));
    } else {
      cart[i].qty += qty;
    }
    notifyListeners();
  }

  void setQty(CartItem item, int qty) {
    if (qty <= 0) {
      cart.remove(item);
    } else {
      item.qty = qty;
    }
    if (cart.isEmpty) appliedPromo = null;
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

  /// Try to apply a promo code. Returns true when the code is valid.
  /// Invalid/blank codes leave any applied promo untouched.
  bool applyPromo(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return false;
    final promo = demoPromos.where((p) => p.code == code).firstOrNull;
    if (promo == null) return false;
    if (identical(appliedPromo, promo)) return true;
    appliedPromo = promo;
    notifyListeners();
    return true;
  }

  void clearPromo() {
    appliedPromo = null;
    notifyListeners();
  }

  /// Undo for "clear bag": put the snapshot back.
  void restoreCart(List<CartItem> items) {
    cart
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  // ---------------------------------------------------------- hero/rails
  /// Slides for the home hero slideshow.
  List<HeroSlide> get heroes => demoHeroes;

  /// Same-category neighbours for the detail screen rail.
  List<Product> relatedTo(Product p) {
    final list = products
        .where((x) => x.id != p.id && x.category == p.category)
        .toList()
      ..sort((a, b) => b.reviews.compareTo(a.reviews));
    return list.take(6).toList();
  }

  // ------------------------------------------------------------- search
  final List<String> trendingTags = const [
    'hoodies', 'sneakers', 'denim', 'streetwear', 'tote bags', 'shades',
  ];

  final List<String> recentSearches = [
    'cloud nine', 'sneakers', 'oversized', 'raw denim',
  ];

  void addRecentSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    recentSearches.removeWhere((r) => r.toLowerCase() == q.toLowerCase());
    recentSearches.insert(0, q);
    if (recentSearches.length > 8) {
      recentSearches.removeLast();
    }
    notifyListeners();
  }

  /// Tolerant search: plurals, near-synonyms, and category words.
  List<Product> search(String rawQuery) {
    final q = rawQuery.trim().toLowerCase();
    if (q.isEmpty) return List.of(products);
    final tokens = q.split(RegExp(r'\s+'));
    return products.where((p) {
      // Name/brand/category/tags only — blurbs mention other product
      // types ("goes with every shoe") and would pollute results.
      final hay =
          '${p.name} ${p.brand} ${p.category} ${p.tags.join(' ')}'.toLowerCase();
      return tokens.every((t) => _termMatches(t, hay, p));
    }).toList();
  }

  static bool _termMatches(String term, String hay, Product p) {
    if (hay.contains(term)) return true;
    final alt = term.length > 3 && term.endsWith('s')
        ? term.substring(0, term.length - 1)
        : '${term}s';
    if (hay.contains(alt)) return true;
    const syn = {
      'sneaker': 'footwear', 'sneakers': 'footwear',
      'shoe': 'footwear', 'shoes': 'footwear',
      'kick': 'footwear', 'kicks': 'footwear',
      'runner': 'footwear', 'runners': 'footwear',
      'boot': 'footwear', 'boots': 'footwear',
      'hoodie': 'streetwear', 'hoodies': 'streetwear',
      'sweat': 'streetwear', 'sweats': 'streetwear',
      'shirt': 'streetwear', 'shirts': 'streetwear',
      'tee': 'streetwear', 'tees': 'streetwear',
      'top': 'streetwear', 'tops': 'streetwear',
      'jean': 'denim', 'jeans': 'denim', 'denim': 'denim',
      'trouser': 'denim', 'trousers': 'denim',
      'cap': 'accessories', 'caps': 'accessories',
      'hat': 'accessories', 'hats': 'accessories',
      'tote': 'accessories', 'totes': 'accessories',
      'shade': 'accessories', 'shades': 'accessories',
      'glasses': 'accessories', 'goggle': 'accessories',
      'jacket': 'winter', 'jackets': 'winter',
      'puffer': 'winter', 'puffers': 'winter',
      'coat': 'winter', 'coats': 'winter',
    };
    final cat = syn[term] ?? syn[alt];
    return cat != null && p.category == cat;
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

  // ------------------------------------------------------------- orders
  /// Place a demo order: snapshots the cart, clears it, returns the order.
  SwagOrder placeOrder({required PayMethod method, required String paymentDetail}) {
    final now = DateTime.now();
    final order = SwagOrder(
      id: 'SK-${10000 + (now.millisecondsSinceEpoch % 90000)}',
      items: List.of(cart),
      subtotal: subtotal,
      discount: discountAmount,
      shipping: shippingFee,
      total: total,
      method: method,
      detail: paymentDetail,
      placedAt: now,
    );
    lastOrder = order;
    cart.clear();
    appliedPromo = null;
    notifyListeners();
    return order;
  }
}
