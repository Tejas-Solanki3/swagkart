import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/swag_icon.dart';
import '../../data/models/product.dart';
import '../../state/app_store.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = swagPad(MediaQuery.sizeOf(context).width);
    return Consumer<SwagAppStore>(
      builder: (context, store, _) {
        final results = store.search(_query);
        final searching = _query.trim().isNotEmpty;
        return ListView(
          padding: EdgeInsets.fromLTRB(pad, 14, pad, 130),
          children: [
            Text(
              'Find your swag',
              style: SwagTheme.display(size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              searching
                  ? '${results.length} match${results.length == 1 ? '' : 'es'} for “${_query.trim()}”'
                  : 'Tell us what you’re feeling today.',
              style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
            ),
            const SizedBox(height: 16),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: SwagColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: searching ? SwagColors.accent : SwagColors.line,
                  width: 1.6,
                ),
                boxShadow: SwagTheme.cardDecoration(radius: 999).boxShadow,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const SwagIcon('search', size: 20, color: SwagColors.inkSoft),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (v) => setState(() => _query = v),
                      style: SwagTheme.body(size: 15),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Try “hoodie”, “runners”, “tote”…',
                        hintStyle: TextStyle(color: SwagColors.inkFaint, fontSize: 14),
                      ),
                    ),
                  ),
                  if (searching)
                    PressableInline(
                      onTap: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: SwagIcon('close', size: 16, color: SwagColors.inkSoft),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (!searching) ...[
              _Label('Popular right now'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in store.trendingTags)
                    _TagPill(
                      label: tag,
                      onTap: () {
                        _controller.text = tag;
                        setState(() => _query = tag);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _Label('Recently searched'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final recent in store.recentSearches)
                    _TagPill(label: recent, muted: true, onTap: () {
                      _controller.text = recent;
                      setState(() => _query = recent);
                    }),
                ],
              ),
              const SizedBox(height: 26),
              _Label('Keep exploring'),
              const SizedBox(height: 12),
            ],
            if (searching && results.isEmpty)
              EmptyState(
                image: 'assets/images/empty-bag.svg',
                title: 'Nothing swagged here',
                subtitle: 'We couldn’t find “${_query.trim()}”. Try “hoodie” or “sneakers”.',
                actionLabel: 'Show everything',
                onAction: () {
                  _controller.clear();
                  setState(() => _query = '');
                },
              )
            else
              _ResultsGrid(results: results, pad: pad),
          ],
        );
      },
    );
  }
}

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({required this.results, required this.pad});

  final List<Product> results;
  final double pad;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - pad * 2;
    final columnCount = swagColumns(width);
    final rows = <List<Product>>[
      for (var i = 0; i < results.length; i += columnCount)
        results.sublist(i, i + columnCount > results.length ? results.length : i + columnCount),
    ];
    return Column(
      children: [
        for (var r = 0; r < rows.length; r++)
          Padding(
            padding: EdgeInsets.only(top: r == 0 ? 0 : 14),
            child: Row(
              children: [
                for (var c = 0; c < rows[r].length; c++) ...[
                  if (c > 0) const SizedBox(width: 14),
                  Expanded(child: ProductCard(product: rows[r][c], stagger: r * columnCount + c)),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: SwagTheme.body(
        size: 11,
        weight: FontWeight.w800,
        color: SwagColors.inkFaint,
        letterSpacing: 1,
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.onTap, this.muted = false});

  final String label;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: muted ? SwagColors.surfaceMist : SwagColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SwagColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!muted)
              const SwagIcon('bolt', size: 12, color: SwagColors.accent),
            if (!muted) const SizedBox(width: 5),
            Text(
              label,
              style: SwagTheme.body(
                size: 13,
                weight: FontWeight.w600,
                color: muted ? SwagColors.inkSoft : SwagColors.ink,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOut);
  }
}

/// Local pressable wrapper (avoids importing pressable twice in one file
/// via different relative paths).
class PressableInline extends StatelessWidget {
  const PressableInline({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}
