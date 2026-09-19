// =============================================================================
// File: lib/state/app_store.dart
// Purpose: Central application state container managing catalog filtering,
//          shopping cart items, wishlist toggles, loyalty points, user auth,
//          and placed orders using ChangeNotifier.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../data/demo_data.dart';
import '../data/models/cart_item.dart';
import '../data/models/order.dart';
import '../data/models/product.dart';
import '../data/models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

const double kFreeShippingThreshold = 999;
const double kFlatShippingFee = 79;

/// Catalog sort options (catalog rail + home rails).
enum SortMode { popular, priceLowHigh, priceHighLow, rating }

/// Main ViewModel / state store for the entire SwagKart application.
///
/// Dispatches UI state updates across:
/// - Product inventory & active filters
/// - Wishlist additions/removals
/// - Shopping bag quantities and promo code discounts
/// - SwagPoints loyalty balance & earnings
/// - User authentication & admin role status
/// - Order submission & history
class SwagAppStore extends ChangeNotifier {
  SwagAppStore() {
    _initAuth();
  }


  // ------------------------------------------------------------- catalog
  final List<Product> products = List.of(demoProducts);
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

  List<Product> byCategory(
    String category, {
    SortMode sort = SortMode.popular,
  }) {
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
  int redeemedPoints = 0;
  int lastEarnedPoints = 0;
  int _demoSwagPoints = 450;

  int get swagPoints => _currentUser?.swagPoints ?? _demoSwagPoints;

  int get cartCount => cart.fold(0, (sum, i) => sum + i.qty);

  double get subtotal => cart.fold(0.0, (sum, i) => sum + i.lineTotal);

  double get promoDiscount =>
      appliedPromo == null ? 0.0 : subtotal * appliedPromo!.pct / 100;

  double get pointsDiscount => redeemedPoints.toDouble().clamp(
    0.0,
    (subtotal - promoDiscount).clamp(0.0, double.infinity),
  );

  double get discountAmount => promoDiscount + pointsDiscount;

  double get afterDiscount => subtotal - discountAmount;

  /// What the shopper actually saves: promo + points + waived shipping.
  double get savings =>
      discountAmount +
      (cart.isNotEmpty && qualifiesFreeShipping ? kFlatShippingFee : 0.0);

  bool get qualifiesFreeShipping => afterDiscount >= kFreeShippingThreshold;

  double get shippingFee =>
      cart.isEmpty || qualifiesFreeShipping ? 0.0 : kFlatShippingFee;

  double get total => afterDiscount + shippingFee;

  void toggleRedeemPoints(bool enable) {
    if (enable) {
      final maxCanRedeem = (subtotal - promoDiscount).floor().clamp(
        0,
        swagPoints,
      );
      redeemedPoints = maxCanRedeem;
    } else {
      redeemedPoints = 0;
    }
    notifyListeners();
  }

  void addSwagPoints(int amount) {
    if (amount <= 0) return;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        swagPoints: _currentUser!.swagPoints + amount,
      );
      FirestoreService.instance.updateUser(_currentUser!);
    } else {
      _demoSwagPoints += amount;
    }
    notifyListeners();
  }

  bool deductSwagPoints(int amount) {
    if (swagPoints < amount) return false;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        swagPoints: (_currentUser!.swagPoints - amount).clamp(0, 999999),
      );
      FirestoreService.instance.updateUser(_currentUser!);
    } else {
      _demoSwagPoints = (_demoSwagPoints - amount).clamp(0, 999999);
    }
    notifyListeners();
    return true;
  }

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
    final list =
        products.where((x) => x.id != p.id && x.category == p.category).toList()
          ..sort((a, b) => b.reviews.compareTo(a.reviews));
    return list.take(6).toList();
  }

  // ------------------------------------------------------------- search
  final List<String> trendingTags = const [
    'hoodies',
    'sneakers',
    'denim',
    'streetwear',
    'tote bags',
    'shades',
  ];

  final List<String> recentSearches = [
    'cloud nine',
    'sneakers',
    'oversized',
    'raw denim',
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
      final hay = '${p.name} ${p.brand} ${p.category} ${p.tags.join(' ')}'
          .toLowerCase();
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
      'sneaker': 'footwear',
      'sneakers': 'footwear',
      'shoe': 'footwear',
      'shoes': 'footwear',
      'kick': 'footwear',
      'kicks': 'footwear',
      'runner': 'footwear',
      'runners': 'footwear',
      'boot': 'footwear',
      'boots': 'footwear',
      'hoodie': 'streetwear',
      'hoodies': 'streetwear',
      'sweat': 'streetwear',
      'sweats': 'streetwear',
      'shirt': 'streetwear',
      'shirts': 'streetwear',
      'tee': 'streetwear',
      'tees': 'streetwear',
      'top': 'streetwear',
      'tops': 'streetwear',
      'jean': 'denim',
      'jeans': 'denim',
      'denim': 'denim',
      'trouser': 'denim',
      'trousers': 'denim',
      'cap': 'accessories',
      'caps': 'accessories',
      'hat': 'accessories',
      'hats': 'accessories',
      'tote': 'accessories',
      'totes': 'accessories',
      'shade': 'accessories',
      'shades': 'accessories',
      'glasses': 'accessories',
      'goggle': 'accessories',
      'jacket': 'winter',
      'jackets': 'winter',
      'puffer': 'winter',
      'puffers': 'winter',
      'coat': 'winter',
      'coats': 'winter',
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
  SwagOrder placeOrder({
    required PayMethod method,
    required String paymentDetail,
  }) {
    final now = DateTime.now();
    final usedPoints = redeemedPoints;
    final order = SwagOrder(
      id: 'SK-${10000 + (now.millisecondsSinceEpoch % 90000)}',
      items: List.of(cart),
      subtotal: subtotal,
      discount: discountAmount,
      shipping: shippingFee,
      total: total,
      method: method,
      detail: usedPoints > 0
          ? '$paymentDetail (🪙 $usedPoints pts redeemed)'
          : paymentDetail,
      placedAt: now,
      status: 'Placed',
    );
    lastOrder = order;
    _allOrders.insert(0, order);
    FirestoreService.instance.saveOrder(
      order,
      userId: currentUser?.uid,
      userEmail: currentUser?.email,
    );

    // Deduct redeemed points if used
    if (usedPoints > 0) {
      deductSwagPoints(usedPoints);
    }

    // Award 10% back in SwagPoints
    lastEarnedPoints = (order.total * 0.10).round();
    if (lastEarnedPoints > 0) {
      addSwagPoints(lastEarnedPoints);
    }

    cart.clear();
    appliedPromo = null;
    redeemedPoints = 0;
    notifyListeners();
    return order;
  }

  /// Directly buy / redeem an item using accumulated SwagPoints.
  SwagOrder buyWithSwagPoints(Product product, String size, String color) {
    final cost = product.swagPointsCost;
    if (swagPoints < cost) {
      throw 'You need $cost SwagPoints for this drop. Your balance: $swagPoints pts.';
    }
    deductSwagPoints(cost);
    final now = DateTime.now();
    final item = CartItem(product: product, size: size, color: color, qty: 1);
    final order = SwagOrder(
      id: 'SK-PTS-${10000 + (now.millisecondsSinceEpoch % 90000)}',
      items: [item],
      subtotal: product.price,
      discount: product.price,
      shipping: 0.0,
      total: 0.0,
      method: PayMethod.upi,
      detail: 'Redeemed with $cost SwagPoints 🪙',
      placedAt: now,
      status: 'Placed',
    );
    lastOrder = order;
    lastEarnedPoints = 0;
    _allOrders.insert(0, order);
    FirestoreService.instance.saveOrder(
      order,
      userId: currentUser?.uid,
      userEmail: currentUser?.email,
    );
    notifyListeners();
    return order;
  }

  // ------------------------------------------------------------- auth & user
  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  void _initAuth() {
    _currentUser = AuthService.instance.currentUser;
    AuthService.instance.userChanges.listen((profile) {
      _currentUser = profile;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    final profile = await AuthService.instance.signIn(
      email: email,
      password: password,
    );
    _currentUser = profile;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String role = 'customer',
  }) async {
    final profile = await AuthService.instance.signUp(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );
    _currentUser = profile;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.instance.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String street,
    required String city,
    required String pincode,
    required String state,
  }) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      name: name,
      phone: phone,
      street: street,
      city: city,
      pincode: pincode,
      state: state,
    );
    await AuthService.instance.updateProfile(updated);
    _currentUser = updated;
    notifyListeners();
  }

  Future<void> signInDemoCustomer() async {
    try {
      await login('tejas@swagkart.in', 'customer123');
    } catch (_) {
      final fallbackCustomer = UserProfile(
        uid: 'demo-customer',
        name: 'Tejas Solanki',
        email: 'tejas@swagkart.in',
        role: 'customer',
        phone: '+91 98765 43210',
        street: '402, High Street Phoenix, Lower Parel',
        city: 'Mumbai',
        pincode: '400013',
        state: 'Maharashtra',
        createdAt: DateTime.now(),
      );
      await FirestoreService.instance.saveUser(fallbackCustomer);
      _currentUser = fallbackCustomer;
      notifyListeners();
    }
  }

  Future<void> signInDemoAdmin() async {
    try {
      await login('admin@swagkart.in', 'admin123');
    } catch (_) {
      final fallbackAdmin = UserProfile(
        uid: 'demo-admin',
        name: 'Store Administrator',
        email: 'admin@swagkart.in',
        role: 'admin',
        phone: '+91 99887 76655',
        street: 'SwagKart HQ, Cyber City',
        city: 'Gurugram',
        pincode: '122002',
        state: 'Haryana',
        createdAt: DateTime.now(),
      );
      await FirestoreService.instance.saveUser(fallbackAdmin);
      _currentUser = fallbackAdmin;
      notifyListeners();
    }
  }

  // ------------------------------------------------------------- admin features
  final List<SwagOrder> _allOrders = [];
  List<SwagOrder> get allOrders => _allOrders;

  Future<void> loadAdminOrders() async {
    final orders = await FirestoreService.instance.getAllOrders();
    _allOrders.clear();
    _allOrders.addAll(orders);
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await FirestoreService.instance.updateOrderStatus(orderId, newStatus);
    for (final o in _allOrders) {
      if (o.id == orderId) {
        o.status = newStatus;
        break;
      }
    }
    if (lastOrder?.id == orderId) {
      lastOrder?.status = newStatus;
    }
    notifyListeners();
  }

  void addAdminProduct(Product product) {
    products.insert(0, product);
    notifyListeners();
  }

  void deleteAdminProduct(String productId) {
    products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
}
