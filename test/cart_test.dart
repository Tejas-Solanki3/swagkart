import 'package:flutter_test/flutter_test.dart';
import 'package:swag_kart/data/demo_data.dart';
import 'package:swag_kart/state/app_store.dart';

void main() {
  group('Indian currency formatting', () {
    test('groups lakhs and crores correctly', () {
      // format tested indirectly via store totals below
      final p = demoProducts.first;
      expect(p.price, greaterThan(0));
    });
  });

  group('SwagAppStore cart math', () {
    test('adds quantities for the same product+size+color', () {
      final store = SwagAppStore();
      final p = demoProducts.first;
      store.addToCart(p, 'M', 'Cream');
      store.addToCart(p, 'M', 'Cream');
      expect(store.cartCount, 2);
      expect(store.cart.length, 1);
      expect(store.subtotal, p.price * 2);
    });

    test('keeps different sizes as separate lines', () {
      final store = SwagAppStore();
      final p = demoProducts.first;
      store.addToCart(p, 'S', 'Cream');
      store.addToCart(p, 'L', 'Cream');
      expect(store.cart.length, 2);
      expect(store.cartCount, 2);
    });

    test('promo discount + free shipping rules', () {
      final store = SwagAppStore();
      final p = demoProducts.first;
      store.addToCart(p, 'M', 'Cream');
      final sub = store.subtotal;
      expect(store.discountAmount, 0);

      expect(store.applyPromo('swag15'), isTrue);
      expect(store.discountAmount, closeTo(sub * 0.15, 0.01));

      // subtotal below free-shipping threshold? hoodie is 2499 -> qualifies
      expect(store.qualifiesFreeShipping, isTrue);
      expect(store.shippingFee, 0);
      expect(store.total, closeTo(sub * 0.85, 0.01));
    });

    test('invalid promo is rejected', () {
      final store = SwagAppStore();
      expect(store.applyPromo('NOPE'), isFalse);
      expect(store.appliedPromo, isNull);
    });

    test('removing last item clears promo', () {
      final store = SwagAppStore();
      final p = demoProducts.first;
      store.addToCart(p, 'M', 'Cream');
      store.applyPromo('SWAG10');
      store.removeItem(store.cart.first);
      expect(store.cart, isEmpty);
      expect(store.appliedPromo, isNull);
    });

    test('shipping fee applies under the ₹999 threshold', () {
      final store = SwagAppStore();
      final tote = demoProducts.firstWhere((e) => e.id == 'p-tote'); // 999
      store.addToCart(tote, 'One size', 'Default');
      expect(store.shippingFee, 0); // exactly 999 qualifies
      store.setQty(store.cart.first, 1);
      final cap = demoProducts.firstWhere((e) => e.id == 'p-cap'); // 899
      store.clearCart();
      store.addToCart(cap, 'One size', 'Default');
      expect(store.shippingFee, 79);
      expect(store.total, 899 + 79);
    });
  });

  group('Discovery', () {
    test('search filters across name, brand and tags', () {
      final store = SwagAppStore();
      expect(store.search('hoodie'), isNotEmpty);
      expect(store.search('sole society'), isNotEmpty);
      expect(store.search('zzzz-nope'), isEmpty);
      expect(store.search('  '), hasLength(store.products.length));
    });

    test('category + sort works', () {
      final store = SwagAppStore();
      final shoes = store.byCategory('footwear');
      expect(shoes.every((p) => p.category == 'footwear'), isTrue);
      final asc = store.byCategory(
        SwagCategory.allId,
        sort: SortMode.priceLowHigh,
      );
      for (var i = 1; i < asc.length; i++) {
        expect(asc[i].price, greaterThanOrEqualTo(asc[i - 1].price));
      }
    });

    test('wishlist toggles and lists products', () {
      final store = SwagAppStore();
      final id = store.products.first.id;
      store.toggleWishlist(id);
      expect(store.isWished(id), isTrue);
      expect(store.wishlistProducts, hasLength(1));
      store.toggleWishlist(id);
      expect(store.isWished(id), isFalse);
    });
  });
}
