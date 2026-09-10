import 'package:flutter/material.dart';

import 'pressable.dart';
import 'swag_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The primary pill button. Optionally sweeps a shine across itself.
class SwagButton extends StatefulWidget {
  const SwagButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.trailingIcon,
    this.background = SwagColors.ink,
    this.foreground = SwagColors.surface,
    this.height = 54,
    this.shine = false,
    this.expanded = true,
    this.fontSize = 16,
  });

  final String label;
  final VoidCallback? onTap;
  final String? icon;
  final String? trailingIcon;
  final Color background;
  final Color foreground;
  final double height;
  final bool shine;
  final bool expanded;
  final double fontSize;

  @override
  State<SwagButton> createState() => _SwagButtonState();
}

class _SwagButtonState extends State<SwagButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    if (widget.shine) {
      _shine.repeat();
    }
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final bg = enabled ? widget.background : SwagColors.ink.withValues(alpha: 0.35);
    return Pressable(
      onTap: enabled ? widget.onTap : null,
      child: Container(
        height: widget.height,
        width: widget.expanded ? double.infinity : null,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(widget.height / 2),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.height / 2),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.shine && enabled)
                AnimatedBuilder(
                  animation: _shine,
                  builder: (context, _) {
                    final t = _shine.value;
                    return Positioned(
                      left: -140 + t * 520,
                      top: -20,
                      bottom: -20,
                      width: 90,
                      child: Transform.rotate(
                        angle: 0.35,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.35),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      SwagIcon(widget.icon!, size: 19, color: widget.foreground),
                      const SizedBox(width: 9),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        style: SwagTheme.display(
                          size: widget.fontSize,
                          weight: FontWeight.w700,
                          color: widget.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      SwagIcon(widget.trailingIcon!, size: 18, color: widget.foreground),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
