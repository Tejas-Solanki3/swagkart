import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swag_button.dart';
import '../../core/widgets/swag_icon.dart';
import '../../state/app_store.dart';
import '../admin/admin_gate.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<SwagAppStore>();
    final saved = store.wishlistProducts;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 130),
      children: [
        Text(
          'Your Account',
          style: SwagTheme.display(size: 26),
        ),
        const SizedBox(height: 16),
        // Profile card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [SwagColors.tangerine, SwagColors.tangerineDeep],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: SwagColors.tangerine.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: SwagColors.cream,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SwagIcon('user', size: 28, color: SwagColors.tangerineDeep),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aarav Sharma',
                      style: SwagTheme.display(size: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'aarav.swag@example.in',
                      style: SwagTheme.body(
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SwagIcon('fire', size: 12, color: SwagColors.butter),
                          const SizedBox(width: 5),
                          Text(
                            'VIP Swag Club',
                            style: SwagTheme.body(
                              size: 10.5,
                              weight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate().scale(begin: const Offset(0.94, 0.94), end: const Offset(1, 1), duration: 450.ms, curve: Curves.easeOutBack).fadeIn(duration: 350.ms),
        const SizedBox(height: 20),
        // Saved items
        _SectionLabel('Saved items'),
        const SizedBox(height: 10),
        Pressable(
          onTap: () => _showSavedSheet(context),
          child: _MenuRow(
            icon: 'heart',
            tint: SwagColors.blush,
            label: 'Saved for later',
            trailing: saved.isEmpty
                ? 'Start loving things'
                : '$saved.itemCount saved',
            trailingStyle: saved.isEmpty
                ? SwagTheme.body(size: 12, color: SwagColors.inkFaint)
                : SwagTheme.body(size: 12, weight: FontWeight.w800, color: SwagColors.tangerine),
          ),
        ),
        const SizedBox(height: 14),
        _SectionLabel('Orders & more'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: SwagColors.paper,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SwagColors.sand),
          ),
          child: Column(
            children: [
              _MenuRow(
                icon: 'package',
                tint: SwagColors.sky,
                label: 'My orders & tracking',
                trailing: 'Phase 2',
                chip: true,
              ),
              const _Divider(),
              _MenuRow(
                icon: 'location',
                tint: SwagColors.pistachio,
                label: 'Saved addresses',
                trailing: 'Phase 2',
                chip: true,
              ),
              const _Divider(),
              _MenuRow(
                icon: 'card',
                tint: SwagColors.lilac,
                label: 'Payment methods',
                trailing: 'Phase 2',
                chip: true,
              ),
              const _Divider(),
              _MenuRow(
                icon: 'shield',
                tint: SwagColors.butter,
                label: 'Help & support',
                onTap: () => _toast(context, 'Support desk opens with Phase 2. Be gentle 😌'),
              ),
              const _Divider(),
              _MenuRow(
                icon: 'sparkles',
                tint: SwagColors.tangerine,
                label: 'About SwagKart',
                onTap: () => _showAbout(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [SwagColors.ink, Color(0xFF3A2E22)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Pressable(
            onTap: () => SwagNav.push(context, (_) => const AdminGate()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: SwagColors.cream.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SwagIcon('lock', size: 19, color: SwagColors.butter),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin console',
                          style: TextStyle(
                            fontFamily: 'Baloo2',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: SwagColors.cream,
                          ),
                        ),
                        Text(
                          'Merchant dashboard · Phase 3',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFFBFB4A6)),
                        ),
                      ],
                    ),
                  ),
                  const SwagIcon('arrow-right', size: 17, color: SwagColors.cream),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Made with ',
                    style: SwagTheme.body(size: 11.5, color: SwagColors.inkFaint),
                  ),
                  const SwagIcon('heart-filled', size: 12, color: SwagColors.tangerine),
                  const SizedBox(width: 4),
                  Text(
                    ' in India · v0.1.0',
                    style: SwagTheme.body(size: 11.5, color: SwagColors.inkFaint),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: SwagTheme.body(size: 13, weight: FontWeight.w600)),
      ),
    );
  }

  void _showSavedSheet(BuildContext context) {
    final store = context.read<SwagAppStore>();
    final saved = store.wishlistProducts;
    if (saved.isEmpty) {
      _toast(context, 'Tap the heart on any product to save it here 💛');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: SwagColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: SwagColors.sand,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const SwagIcon('heart-filled', size: 18, color: SwagColors.tangerine),
                    const SizedBox(width: 8),
                    Text(
                      'Saved items',
                      style: SwagTheme.display(size: 20),
                    ),
                    const Spacer(),
                    Text(
                      '${saved.length} item${saved.length == 1 ? '' : 's'}',
                      style: SwagTheme.body(size: 12, color: SwagColors.inkSoft),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: saved.length,
                  itemBuilder: (context, i) => ProductCard(product: saved[i], stagger: i),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: SwagColors.ink,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SwagIcon('bag', size: 30, color: SwagColors.cream),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'SwagKart',
                style: SwagTheme.display(size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                'A playful Indian storefront demo. Phase 1 ships the '
                'storefront, discovery and bag — checkout, orders, '
                'accounts and the admin console follow.',
                textAlign: TextAlign.center,
                style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: SwagButton(
                  label: 'Love it',
                  icon: 'heart',
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 62),
      child: Divider(height: 1, color: SwagColors.sandSoft),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.tint,
    required this.label,
    this.trailing,
    this.trailingStyle,
    this.chip = false,
    this.onTap,
  });

  final String icon;
  final Color tint;
  final String label;
  final String? trailing;
  final TextStyle? trailingStyle;
  final bool chip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SwagIcon(icon, size: 19, color: SwagColors.ink),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: SwagTheme.body(size: 14, weight: FontWeight.w700),
              ),
            ),
            if (trailing != null)
              chip
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: SwagColors.sandSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        trailing!,
                        style: SwagTheme.body(size: 10.5, weight: FontWeight.w800, color: SwagColors.inkSoft),
                      ),
                    )
                  : Text(
                      trailing!,
                      style: trailingStyle ??
                          SwagTheme.body(size: 12, color: SwagColors.inkFaint),
                    ),
            const SizedBox(width: 8),
            if (!chip) const SwagIcon('arrow-right', size: 15, color: SwagColors.inkFaint),
          ],
        ),
      ),
    );
  }
}
