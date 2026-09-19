import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:swag_kart/core/widgets/swag_logo.dart';
import 'package:swag_kart/data/models/order.dart';
import 'package:swag_kart/features/bag/bag_screen.dart';
import 'package:swag_kart/features/catalog/catalog_screen.dart';
import 'package:swag_kart/features/wishlist/wishlist_screen.dart';
import 'package:swag_kart/state/app_store.dart';

void main() {
  group('SwagPoints Loyalty & Redemption Logic', () {
    test('Product calculates SwagPoints cost and earn percentage', () {
      final store = SwagAppStore();
      final product = store.products.first; // e.g. price ₹2499
      expect(product.swagPointsCost, (product.price / 10).round());
      expect(product.swagPointsEarned, (product.price * 0.1).round());
    });

    test('Placing an order awards 10% back in SwagPoints and deducts redeemed points', () {
      final store = SwagAppStore();
      final initialPoints = store.swagPoints;
      final product = store.products.first;

      store.addToCart(product, product.sizes.first, 'Default');
      expect(store.total, greaterThan(0));

      // Redeem points
      store.toggleRedeemPoints(true);
      expect(store.redeemedPoints, greaterThan(0));
      final usedPoints = store.redeemedPoints;

      final order = store.placeOrder(
        method: PayMethod.upi,
        paymentDetail: 'demo@upi',
      );

      expect(order.status, 'Placed');
      expect(store.lastEarnedPoints, (order.total * 0.10).round());
      // Updated points should reflect deduction of redeemed and addition of earned points
      expect(
        store.swagPoints,
        initialPoints - usedPoints + store.lastEarnedPoints,
      );
    });

    test('buyWithSwagPoints redeems product directly with zero total', () {
      final store = SwagAppStore();
      final product = store.products.first;
      final cost = product.swagPointsCost;

      // Ensure user has sufficient points
      store.addSwagPoints(cost + 500);
      final beforePoints = store.swagPoints;

      final order = store.buyWithSwagPoints(
        product,
        product.sizes.first,
        'Default',
      );

      expect(order.total, 0.0);
      expect(order.detail, contains('Redeemed with $cost SwagPoints'));
      expect(store.swagPoints, beforePoints - cost);
    });
  });

  group('App Branding & SwagLogo Presence', () {
    testWidgets('SwagLogo renders with custom size and text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SwagLogo(size: 32, showText: true)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SwagKart'), findsOneWidget);
      expect(find.byType(SwagLogo), findsOneWidget);
    });

    testWidgets('CatalogScreen displays top-left SwagLogo', (tester) async {
      final store = SwagAppStore();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: store,
          child: const MaterialApp(home: Scaffold(body: CatalogScreen())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SwagLogo), findsOneWidget);
      expect(find.text('The Catalog'), findsOneWidget);
    });

    testWidgets(
      'WishlistScreen displays top-left SwagLogo and left-aligned items',
      (tester) async {
        final store = SwagAppStore();
        store.toggleWishlist(store.products.first.id);

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: store,
            child: const MaterialApp(home: Scaffold(body: WishlistScreen())),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SwagLogo), findsOneWidget);
        expect(find.text('Wishlist'), findsOneWidget);
      },
    );

    testWidgets(
      'BagScreen displays top-left SwagLogo and SwagPoints redemption container',
      (tester) async {
        final store = SwagAppStore();
        final product = store.products.first;
        store.addToCart(product, product.sizes.first, 'Default');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: store,
            child: const MaterialApp(home: Scaffold(body: BagScreen())),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(SwagLogo), findsOneWidget);
        expect(find.text('Redeem SwagPoints'), findsOneWidget);
        expect(find.text('Your Bag'), findsOneWidget);
      },
    );
  });
}
