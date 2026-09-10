import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/app_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFF8F3EA),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const SwagKartApp());
}

class SwagKartApp extends StatelessWidget {
  const SwagKartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SwagAppStore>(
      create: (_) => SwagAppStore(),
      child: const SwagKartMaterialApp(),
    );
  }
}
