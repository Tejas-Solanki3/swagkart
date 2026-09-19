import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swag_kart/features/home/home_screen.dart';
import 'package:swag_kart/main.dart';

void main() {
  testWidgets('app boots from splash into the 5-tab shell', (tester) async {
    await tester.pumpWidget(const SwagKartApp());

    // Splash content lands (tagline fades in ~1.15s).
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('Swag. Sorted. Delivered.'), findsOneWidget);

    // Auto-leave fires at ~2.1s, then the route transition (~340ms).
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 400));

    // Ensure we reach AuthGate / LoginScreen
    await tester.pump(const Duration(milliseconds: 500));
    final demoShopper = find.text('Demo Shopper');
    if (demoShopper.evaluate().isEmpty) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pump();
    }
    if (demoShopper.evaluate().isNotEmpty) {
      await tester.tap(demoShopper);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 400));
    }

    // Home tab (onstage): header + bottom nav.
    expect(find.text('Mumbai, IN'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('Bag'), findsOneWidget);

    // Every tab is laid out by the IndexedStack (inactive tabs are
    // offstage to finders in modern Flutter).
    expect(find.text('The Catalog', skipOffstage: false), findsOneWidget);
    expect(find.text('Nothing saved yet', skipOffstage: false), findsOneWidget);
    expect(find.text('Your Account', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Your bag is feeling light', skipOffstage: false),
      findsOneWidget,
    );

    // Scroll the home feed down to reveal the trending rail and
    // verify product discovery renders demo products.
    await tester.drag(find.byType(HomeScreen).first, const Offset(0, -320));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Trending now'), findsOneWidget);
    expect(find.text('Cloud Nine Hoodie'), findsWidgets);
    expect(find.text('Rangoli Runner'), findsWidgets);

    // Tab switch: tap Bag — the empty bag screen becomes visible.
    await tester.tap(find.text('Bag'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Your bag is feeling light'), findsOneWidget);
    expect(find.text('Start shopping'), findsOneWidget);

    // flutter_animate schedules Future.delayed timers for its `delay:`
    // argument and does not cancel them on unmount. Advance the fake
    // clock in chunks larger than the hero's 4200ms periodic so every
    // delay (bell wobble 2400ms, slide CTA 600ms) fires — and any
    // animation it kicks off settles — while the tree is still mounted.
    await tester.pump(const Duration(milliseconds: 4500));
    await tester.pump(const Duration(milliseconds: 4500));

    // Tear down the tree so periodic timers/tickers are cancelled.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
