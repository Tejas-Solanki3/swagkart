import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:swag_kart/features/admin/admin_dashboard_screen.dart';
import 'package:swag_kart/features/wishlist/wishlist_screen.dart';
import 'package:swag_kart/state/app_store.dart';

void main() {
  testWidgets(
    'AdminDashboardScreen header never overflows at 360px narrow phone width',
    (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final store = SwagAppStore();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: store,
          child: const MaterialApp(home: AdminDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header controls are present
      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.byTooltip('Back to Store'), findsOneWidget);
      expect(find.byTooltip('Sign Out'), findsOneWidget);
    },
  );

  testWidgets(
    'WishlistScreen renders responsively on phone (360px) and web (1440px)',
    (tester) async {
      final store = SwagAppStore();
      // Add product to wishlist
      store.toggleWishlist(store.products.first.id);

      // Test phone width
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: store,
          child: const MaterialApp(home: Scaffold(body: WishlistScreen())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.text('1 item'), findsOneWidget);

      // Test web width
      tester.view.physicalSize = const Size(1440, 900);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: store,
          child: const MaterialApp(home: Scaffold(body: WishlistScreen())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Wishlist'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );
}
