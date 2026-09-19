// =============================================================================
// File: lib/core/widgets/section_header.dart
// Purpose: Standard section header featuring an accent bar, title with animated
//          sparkle icon, optional subtitle, and 'See all' tap navigation.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'swag_icon.dart';

/// Reusable section title bar used on the home and catalog screens.
///
/// Features:
/// - Signature coral accent indicator pillar on the left
/// - Bold Baloo 2 section headline
/// - Looping playful sparkle wiggle animation
/// - Optional 'See all' button linking to the full category list
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.seeAllLabel = 'See all',
  });


  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 22,
            decoration: BoxDecoration(
              color: SwagColors.accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: SwagTheme.display(size: 20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 7),
                    SwagIcon('sparkles', size: 16, color: SwagColors.butter)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .rotate(begin: 0, end: 0.08, duration: 1600.ms),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: SwagTheme.body(size: 12, color: SwagColors.inkSoft),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    seeAllLabel,
                    style: SwagTheme.body(
                      size: 13,
                      weight: FontWeight.w700,
                      color: SwagColors.accent,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const SwagIcon(
                    'arrow-right',
                    size: 14,
                    color: SwagColors.accent,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
