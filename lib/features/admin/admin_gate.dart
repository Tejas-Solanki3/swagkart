// =============================================================================
// File: lib/features/admin/admin_gate.dart
// Purpose: Security gate guarding the admin console requiring merchant PIN
//          verification (1234) or direct administrator credentials.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swag_button.dart';
import '../../core/widgets/swag_icon.dart';
import '../../state/app_store.dart';
import '../auth/login_screen.dart';
import 'admin_dashboard_screen.dart';

/// Screen requiring merchant PIN verification (1234 or 'admin') before
/// unlocking the merchant management dashboard.
class AdminGate extends StatefulWidget {
  const AdminGate({super.key});

  @override
  State<AdminGate> createState() => _AdminGateState();
}


class _AdminGateState extends State<AdminGate> {
  final _pinController = TextEditingController();
  bool _pinError = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPinAndOpen(SwagAppStore store) async {
    final pin = _pinController.text.trim();
    if (pin == '1234' || pin == 'admin') {
      try {
        if (!store.isAdmin) {
          await store.signInDemoAdmin();
        }
      } catch (_) {
        // Fallback already guaranteed inside signInDemoAdmin
      }
      if (mounted) {
        SwagNav.pushReplacement(context, (_) => const AdminDashboardScreen());
      }
    } else {
      setState(() => _pinError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SwagAppStore>();

    // If already logged in as admin, show dashboard directly
    if (store.isAdmin) {
      return const AdminDashboardScreen();
    }

    return Scaffold(
      backgroundColor: SwagColors.ink,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DotPainter())),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Pressable(
                                  onTap: () => SwagNav.pop(context),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: SwagIcon(
                                        'arrow-left',
                                        size: 20,
                                        color: SwagColors.canvas,
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'SWAGKART MERCHANT',
                                  style: SwagTheme.body(
                                    size: 12,
                                    weight: FontWeight.w800,
                                    color: SwagColors.canvas.withValues(
                                      alpha: 0.6,
                                    ),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 86,
                                  height: 86,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        SwagColors.accent,
                                        SwagColors.butter,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: SwagColors.accent.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 40,
                                        offset: const Offset(0, 16),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: SwagIcon(
                                      'lock',
                                      size: 38,
                                      color: SwagColors.ink,
                                    ),
                                  ),
                                ).animate().scale(
                                  duration: 500.ms,
                                  curve: Curves.easeOutBack,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Admin Console',
                                  style: SwagTheme.display(
                                    size: 28,
                                    color: SwagColors.canvas,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Enter Merchant PIN (default: 1234) or log in with your administrator account.',
                                  textAlign: TextAlign.center,
                                  style: SwagTheme.body(
                                    size: 13,
                                    color: SwagColors.canvas.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // PIN Display & Input
                                Container(
                                  width: 280,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _pinError
                                          ? SwagColors.accent
                                          : Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _pinController,
                                    obscureText: true,
                                    obscuringCharacter: '●',
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      letterSpacing: 12,
                                      color: SwagColors.canvas,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      hintText: '••••',
                                      hintStyle: TextStyle(
                                        fontSize: 26,
                                        letterSpacing: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 16,
                                          ),
                                    ),
                                    onSubmitted: (_) =>
                                        _verifyPinAndOpen(store),
                                  ),
                                ),
                                if (_pinError) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Incorrect PIN. Try 1234 or sign in below.',
                                    style: SwagTheme.body(
                                      size: 12,
                                      color: SwagColors.accent,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 18),

                                // Unlock CTA
                                SizedBox(
                                  width: 280,
                                  child: SwagButton(
                                    label: 'Unlock Console',
                                    icon: 'arrow-right',
                                    background: SwagColors.butter,
                                    foreground: SwagColors.ink,
                                    height: 48,
                                    onTap: () => _verifyPinAndOpen(store),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Sign in as admin
                                TextButton(
                                  onPressed: () => SwagNav.push(
                                    context,
                                    (_) => const LoginScreen(),
                                  ),
                                  child: Text(
                                    'Sign in with Admin Email & Password',
                                    style: SwagTheme.body(
                                      size: 12.5,
                                      weight: FontWeight.w700,
                                      color: SwagColors.canvas.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
                            child: SwagButton(
                              label: 'Back to the store',
                              icon: 'bag',
                              background: SwagColors.canvas,
                              foreground: SwagColors.ink,
                              height: 50,
                              onTap: () => SwagNav.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SwagColors.canvas.withValues(alpha: 0.05)
      ..strokeWidth = 2;
    const step = 34.0;
    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
