import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

class SwagKartMaterialApp extends StatelessWidget {
  const SwagKartMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwagKart',
      debugShowCheckedModeBanner: false,
      theme: SwagTheme.light(),
      home: const SplashScreen(),
    );
  }
}
