import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shell/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _waves = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );

  Timer? _leaveTimer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _leaveTimer = Timer(const Duration(milliseconds: 2100), _leave);
  }

  void _leave() {
    if (_leaving || !mounted) return;
    _leaving = true;
    _exit.forward().whenComplete(() {
      if (mounted) SwagNav.pushReplacement(context, (_) => const AppShell());
    });
  }

  @override
  void dispose() {
    _leaveTimer?.cancel();
    _waves.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: SwagColors.canvas),
          // Bottom candy waves
          AnimatedBuilder(
            animation: _waves,
            builder: (context, _) =>
                CustomPaint(painter: _WavePainter(phase: _waves.value)),
          ),
          // Content
          ScaleTransition(
            scale: AlwaysStoppedAnimation(
              1 + 0.06 * Curves.easeIn.transform(_exit.value),
            ),
            child: FadeTransition(
              opacity: _exit,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/logo.svg',
                      width: 116,
                      height: 116,
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.4, 0.4),
                          end: const Offset(1, 1),
                          duration: 650.ms,
                          curve: Curves.elasticOut,
                          delay: 120.ms,
                        )
                        .moveY(begin: -40, end: 0, duration: 650.ms, delay: 120.ms),
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: 'SwagKart'.split('').asMap().entries.map((e) {
                        final i = e.key;
                        final ch = e.value;
                        return Text(
                          ch,
                          style: SwagTheme.display(
                            size: 42,
                            weight: FontWeight.w800,
                            color: i == 0 ? SwagColors.accent : SwagColors.ink,
                          ),
                        ).animate(
                          delay: (420 + i * 55).ms,
                        ).moveY(begin: 26, end: 0, duration: 520.ms, curve: Curves.easeOutBack).fadeIn(duration: 300.ms);
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Swag. Sorted. Delivered.',
                      style: SwagTheme.body(
                        size: 14,
                        weight: FontWeight.w600,
                        color: SwagColors.inkSoft,
                      ),
                    ).animate(delay: 1150.ms).fadeIn(duration: 500.ms).moveY(begin: 12, end: 0, duration: 500.ms),
                  ],
                ),
              ),
            ),
          ),
          // Bottom loader dots
          Positioned(
            bottom: 46,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: SwagColors.accent,
                    shape: BoxShape.circle,
                  ),
                ).animate(
                  onPlay: (c) => c.repeat(reverse: true),
                  delay: (i * 160).ms,
                ).scale(begin: const Offset(0.6, 0.6), end: const Offset(1.25, 1.25), duration: 550.ms).fade(begin: 0.4, end: 1, duration: 550.ms);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    _paintWave(
      canvas,
      size,
      0.86,
      26,
      phase * math.pi * 2,
      SwagColors.butter.withValues(alpha: 0.35),
    );
    _paintWave(
      canvas,
      size,
      0.93,
      18,
      phase * math.pi * 2 + 1.4,
      SwagColors.accent.withValues(alpha: 0.28),
    );
  }

  void _paintWave(
    Canvas canvas,
    Size size,
    double baseY,
    double amplitude,
    double offset,
    Color color,
  ) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 4) {
      final y = size.height * baseY + math.sin(x / 64 + offset) * amplitude;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.phase != phase;
}
