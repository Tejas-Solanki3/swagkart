import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:swag_kart/features/home/home_screen.dart';
import 'package:swag_kart/state/app_store.dart';

/// Loads the app's real fonts so text metrics in the test match the device.
Future<void> loadSwagFonts() async {
  const files = <String, List<String>>{
    'Baloo2': ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold'],
    'Inter': ['Regular', 'Medium', 'SemiBold', 'Bold'],
  };
  for (final entry in files.entries) {
    for (final weight in entry.value) {
      final data = await rootBundle.load('assets/fonts/${entry.key}-$weight.ttf');
      await loadFontFromList(data.buffer.asUint8List(), fontFamily: entry.key);
    }
  }
}

void main() {
  testWidgets('hero CTA pills never overflow at phone width', (tester) async {
    await tester.runAsync(loadSwagFonts);

    // 360x740 — the narrowest common phone width. If the hero CTA
    // pills fit here they fit everywhere; in widget tests an overflow
    // throws and fails the test.
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: SwagAppStore(),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Material(child: HomeScreen()),
        ),
      ),
    );

    // Cycle through every hero slide (4200ms auto-advance + CTA entry).
    // In widget tests a RenderFlex overflow throws and fails the test,
    // so a green run proves the pill rows fit at this width.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 4400));
      await tester.pump();
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
