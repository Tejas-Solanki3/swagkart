import 'package:flutter_test/flutter_test.dart';
import 'package:swag_kart/data/demo_data.dart';
import 'package:swag_kart/state/app_store.dart';

void main() {
  test('promo codes apply, persist on invalid attempts, clear when bag empties', () {
    final store = SwagAppStore();
    final p = demoProducts.first;
    store.addToCart(p, p.sizes.first, 'Default');
    final subtotal = store.subtotal;

    // Valid code (lowercase + spaces should still match).
    expect(store.applyPromo('  swag15 '), isTrue);
    expect(store.appliedPromo?.code, 'SWAG15');
    expect(store.discountAmount, greaterThan(0));
    expect(store.afterDiscount, lessThan(subtotal));
    expect(store.total, lessThan(subtotal + 79));

    // Unknown code does not clobber the applied promo.
    expect(store.applyPromo('NOPE'), isFalse);
    expect(store.appliedPromo?.code, 'SWAG15');

    // Empty / blank code rejected.
    expect(store.applyPromo(''), isFalse);
    expect(store.applyPromo('   '), isFalse);

    // Second valid code swaps the discount.
    expect(store.applyPromo('SWAG10'), isTrue);
    expect(store.appliedPromo?.code, 'SWAG10');
    expect(store.discountAmount, lessThan(subtotal * 0.15));

    // Emptying the bag clears the promo.
    store.clearCart();
    expect(store.appliedPromo, isNull);
  });
}
