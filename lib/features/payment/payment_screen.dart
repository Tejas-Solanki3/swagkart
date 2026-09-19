// =============================================================================
// File: lib/features/payment/payment_screen.dart
// Purpose: Checkout payment screen providing payment method selection (UPI,
//          Credit/Debit Card, COD), interactive card flip preview, and simulated transaction gateway.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swag_button.dart';
import '../../core/widgets/swag_icon.dart';
import '../../core/widgets/swag_logo.dart';
import '../../data/models/order.dart';
import '../../state/app_store.dart';
import 'order_placed_screen.dart';

/// Reference-style payment screen: method picker, live card preview,
/// UPI id field, COD note — then a simulated processing step and order placement.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});


  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  PayMethod _method = PayMethod.upi;
  final _upiCtrl = TextEditingController(text: 'tejas@okaxis');
  final _cardCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(text: 'Tejas Solanki');

  Map<String, String> _errors = {};
  bool _processing = false;
  String _processingLabel = 'Processing…';
  Timer? _procTimer;

  @override
  void dispose() {
    _procTimer?.cancel();
    _upiCtrl.dispose();
    _cardCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ formatting
  void _onCardChanged(String v) {
    final digits = v.replaceAll(RegExp(r'\D'), '').substring(0, 16);
    final grouped = digits.isEmpty
        ? ''
        : digits.replaceAllMapped(RegExp(r'(\d{4})(?=\d)'), (m) => '${m[1]} ');
    if (grouped != _cardCtrl.text) {
      final offset = _cardCtrl.selection.baseOffset;
      _cardCtrl.text = grouped;
      _cardCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: grouped.length.clamp(0, offset)),
      );
    }
    _clearError('card');
  }

  void _onExpiryChanged(String v) {
    final digits = v.replaceAll(RegExp(r'\D'), '').substring(0, 4);
    var out = digits;
    if (digits.length >= 3) {
      out = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    if (out != _expCtrl.text) {
      _expCtrl.text = out;
      _expCtrl.selection = const TextSelection.collapsed(offset: 999);
    }
    _clearError('exp');
  }

  void _onCvvChanged(String v) {
    final digits = v.replaceAll(RegExp(r'\D'), '').substring(0, 3);
    if (digits != _cvvCtrl.text) {
      _cvvCtrl.text = digits;
      _cvvCtrl.selection = const TextSelection.collapsed(offset: 999);
    }
    _clearError('cvv');
  }

  void _onUpiChanged(String v) {
    _upiCtrl.value = TextEditingValue(
      text: v.toLowerCase().replaceAll(' ', ''),
      selection: TextSelection.collapsed(offset: v.length),
    );
    _clearError('upi');
  }

  void _clearError(String key) {
    if (_errors.containsKey(key)) {
      setState(() => _errors.remove(key));
    }
  }

  String _cardDisplay() {
    final digits = _cardCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '••••  ••••  ••••  ••••';
    final padded = digits.padRight(16, '•');
    final buf = StringBuffer();
    for (var i = 0; i < 16; i++) {
      if (i > 0 && i % 4 == 0) buf.write('  ');
      buf.write(padded[i]);
    }
    return buf.toString();
  }

  // ------------------------------------------------------------ validation
  bool _validate() {
    final errors = <String, String>{};
    switch (_method) {
      case PayMethod.upi:
        final upi = _upiCtrl.text.trim();
        if (!RegExp(r'^[\w.\-]{2,}@[a-zA-Z]{2,}$').hasMatch(upi)) {
          errors['upi'] = 'Enter a valid UPI id, like tejas@okaxis';
        }
      case PayMethod.card:
        if (_cardCtrl.text.replaceAll(RegExp(r'\D'), '').length != 16) {
          errors['card'] = 'Card number must be 16 digits';
        }
        final exp = _expCtrl.text.replaceAll(RegExp(r'\D'), '');
        if (exp.length != 4) {
          errors['exp'] = 'MM/YY';
        } else {
          final mm = int.tryParse(exp.substring(0, 2)) ?? 0;
          final yy = int.tryParse(exp.substring(2)) ?? 0;
          if (mm < 1 || mm > 12 || yy < 26) {
            errors['exp'] = 'Check the date';
          }
        }
        if (_cvvCtrl.text.length != 3) errors['cvv'] = '3 digits';
        if (_nameCtrl.text.trim().length < 3) {
          errors['name'] = 'Name as printed on the card';
        }
      case PayMethod.cod:
        break;
    }
    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  void _pay() {
    if (_processing) return;
    if (!_validate()) return;
    final label = switch (_method) {
      PayMethod.upi => 'Requesting UPI collect…',
      PayMethod.card => 'Charging your card…',
      PayMethod.cod => 'Placing your order…',
    };
    setState(() {
      _processing = true;
      _processingLabel = label;
    });
    _procTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final store = context.read<SwagAppStore>();
      final detail = switch (_method) {
        PayMethod.upi => _upiCtrl.text.trim(),
        PayMethod.card =>
          '•••• ${_cardCtrl.text.replaceAll(RegExp(r'\D'), '').substring(12)}',
        PayMethod.cod => 'Cash on delivery',
      };
      final order = store.placeOrder(method: _method, paymentDetail: detail);
      if (mounted) {
        SwagNav.pushReplacement(
          context,
          (_) => OrderPlacedScreen(order: order),
        );
      }
    });
  }

  // --------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final store = context.watch<SwagAppStore>();
    return Scaffold(
      backgroundColor: SwagColors.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            if (store.cart.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Nothing to pay for',
                        style: SwagTheme.display(size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your bag is empty, swagstar.',
                        style: SwagTheme.body(
                          size: 13,
                          color: SwagColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 220,
                        child: SwagButton(
                          label: 'Start shopping',
                          trailingIcon: 'arrow-right',
                          onTap: () => SwagNav.popToRoot(context),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                children: [
                  // Top bar
                  Row(
                    children: [
                      _RoundButton(
                        icon: 'arrow-left',
                        onTap: () => SwagNav.pop(context),
                      ),
                      const SizedBox(width: 10),
                      const SwagLogo(size: 28, showText: true),
                      const Spacer(),
                      Text('Payment', style: SwagTheme.display(size: 18)),
                      const Spacer(),
                      const _RoundButton(icon: 'dots', onTap: null),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Method picker
                  Text(
                    'Payment Method',
                    style: SwagTheme.display(size: 16, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (final m in PayMethod.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _MethodButton(
                            method: m,
                            selected: m == _method,
                            onTap: () => setState(() {
                              _method = m;
                              _errors = {};
                            }),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Method body
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: switch (_method) {
                      PayMethod.card => _CardPanel(
                        preview: _CardPreview(
                          number: _cardDisplay(),
                          name: _nameCtrl.text.trim().isEmpty
                              ? 'YOUR NAME'
                              : _nameCtrl.text.trim().toUpperCase(),
                          expiry: _expCtrl.text.isEmpty
                              ? 'MM/YY'
                              : _expCtrl.text,
                        ),
                        cardController: _cardCtrl,
                        expController: _expCtrl,
                        cvvController: _cvvCtrl,
                        nameController: _nameCtrl,
                        errors: _errors,
                        onCard: _onCardChanged,
                        onExp: _onExpiryChanged,
                        onCvv: _onCvvChanged,
                        onName: (v) => _clearError('name'),
                      ),
                      PayMethod.upi => _UpiPanel(
                        controller: _upiCtrl,
                        error: _errors['upi'],
                        onChanged: _onUpiChanged,
                      ),
                      PayMethod.cod => const _CodPanel(),
                    },
                  ),
                  const SizedBox(height: 20),
                  // Amount summary
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: SwagTheme.cardDecoration(radius: 20),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paying now',
                              style: SwagTheme.body(
                                size: 12,
                                color: SwagColors.inkSoft,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              inr(store.total),
                              style: SwagTheme.display(
                                size: 20,
                                weight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (store.savings > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: SwagColors.mintSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'You save ${inr(store.savings)}',
                              style: SwagTheme.body(
                                size: 11.5,
                                weight: FontWeight.w800,
                                color: SwagColors.mintDeep,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: SwagColors.butterSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: SwagColors.butter.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Loyalty Reward',
                                style: SwagTheme.body(
                                  size: 12.5,
                                  weight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'You will earn +${(store.total * 0.10).round()} SwagPoints (10% back)',
                                style: SwagTheme.body(
                                  size: 11.5,
                                  color: SwagColors.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (store.redeemedPoints > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: SwagColors.ink,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${store.redeemedPoints} pts used',
                              style: SwagTheme.body(
                                size: 10,
                                weight: FontWeight.w800,
                                color: SwagColors.butter,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SwagButton(
                    label: _method == PayMethod.cod
                        ? 'Place Order'
                        : 'Pay ${inr(store.total)}',
                    icon: 'lock',
                    height: 58,
                    onTap: _pay,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SwagIcon(
                        'shield',
                        size: 14,
                        color: SwagColors.inkFaint,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Demo checkout — no real money moves.',
                        style: SwagTheme.body(
                          size: 11.5,
                          color: SwagColors.inkFaint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            // Processing overlay
            if (_processing)
              Positioned.fill(
                child: ModalBarrier(
                  color: SwagColors.ink.withValues(alpha: 0.45),
                ),
              ),
            if (_processing)
              Center(
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(22),
                  decoration: SwagTheme.cardDecoration(radius: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 42,
                        height: 42,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          color: SwagColors.accent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _processingLabel,
                        textAlign: TextAlign.center,
                        style: SwagTheme.body(
                          size: 13.5,
                          weight: FontWeight.w700,
                          color: SwagColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onTap});

  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: SwagTheme.iconButtonDecoration(),
        child: Center(child: SwagIcon(icon, size: 19, color: SwagColors.ink)),
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  const _MethodButton({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PayMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: selected ? SwagColors.mistSoft : SwagColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? SwagColors.mist.withValues(alpha: 0.6)
                : SwagColors.line,
            width: selected ? 1.8 : 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: SwagColors.mist.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: switch (method) {
            PayMethod.upi => Text(
              'UPI',
              style: SwagTheme.display(
                size: 12,
                weight: FontWeight.w800,
                color: selected ? SwagColors.mistDeep : SwagColors.inkSoft,
              ),
            ),
            PayMethod.card => SwagIcon(
              'card',
              size: 24,
              color: selected ? SwagColors.mistDeep : SwagColors.inkSoft,
            ),
            PayMethod.cod => SwagIcon(
              'truck',
              size: 24,
              color: selected ? SwagColors.mistDeep : SwagColors.inkSoft,
            ),
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.number,
    required this.name,
    required this.expiry,
  });

  final String number;
  final String name;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A4E9E), Color(0xFF7B6FD6)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A4E9E).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CARD TYPE',
                style: SwagTheme.body(
                  size: 10,
                  weight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.75),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                'SWAGBANK',
                style: SwagTheme.display(
                  size: 15,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            number,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SwagTheme.body(
                    size: 12.5,
                    weight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                'Valid $expiry',
                style: SwagTheme.body(
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardPanel extends StatelessWidget {
  const _CardPanel({
    required this.preview,
    required this.cardController,
    required this.expController,
    required this.cvvController,
    required this.nameController,
    required this.errors,
    required this.onCard,
    required this.onExp,
    required this.onCvv,
    required this.onName,
  });

  final Widget preview;
  final TextEditingController cardController;
  final TextEditingController expController;
  final TextEditingController cvvController;
  final TextEditingController nameController;
  final Map<String, String> errors;
  final ValueChanged<String> onCard;
  final ValueChanged<String> onExp;
  final ValueChanged<String> onCvv;
  final ValueChanged<String> onName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        preview,
        _Field(
          label: 'Card Number',
          controller: cardController,
          hintText: '1234 5678 9012 3456',
          onChanged: onCard,
          keyboardType: TextInputType.number,
          trailing: const SwagIcon('card', size: 19, color: SwagColors.inkSoft),
          error: errors['card'],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Expiry Date',
                controller: expController,
                hintText: 'MM/YY',
                onChanged: onExp,
                keyboardType: TextInputType.number,
                error: errors['exp'],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Field(
                label: 'CVV',
                controller: cvvController,
                hintText: '•••',
                onChanged: onCvv,
                keyboardType: TextInputType.number,
                obscure: true,
                error: errors['cvv'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Field(
          label: 'Card Holder Name',
          controller: nameController,
          hintText: 'Name as printed on the card',
          onChanged: onName,
          error: errors['name'],
        ),
      ],
    );
  }
}

class _UpiPanel extends StatelessWidget {
  const _UpiPanel({
    required this.controller,
    required this.onChanged,
    this.error,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: SwagTheme.cardDecoration(radius: 20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: SwagColors.mistSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: SwagIcon('bolt', size: 24, color: SwagColors.mistDeep),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPI — the fastest way',
                      style: SwagTheme.display(
                        size: 15,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'GPay, PhonePe, Paytm — your pick.',
                      style: SwagTheme.body(
                        size: 12,
                        color: SwagColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Field(
          label: 'UPI ID',
          controller: controller,
          hintText: 'tejas@okaxis',
          onChanged: onChanged,
          error: error,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SwagColors.mistSoft,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: SwagIcon('shield', size: 17, color: SwagColors.mistDeep),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'A collect request will pop up in your UPI app. Approve it there '
                  'to complete payment — we will never ask for your PIN.',
                  style: SwagTheme.body(
                    size: 12,
                    color: SwagColors.mistDeep,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CodPanel extends StatelessWidget {
  const _CodPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SwagTheme.cardDecoration(radius: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: SwagColors.mintSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: SwagIcon('truck', size: 24, color: SwagColors.mintDeep),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash on Delivery',
                  style: SwagTheme.display(size: 15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pay in cash or via UPI when your order arrives at your door. '
                  'Keep exact change handy — our riders carry limited change.',
                  style: SwagTheme.body(
                    size: 12,
                    color: SwagColors.inkSoft,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.keyboardType,
    this.trailing,
    this.obscure = false,
    this.error,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final bool obscure;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SwagTheme.body(
            size: 12,
            weight: FontWeight.w800,
            color: SwagColors.inkSoft,
          ),
        ),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: SwagColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: error != null ? SwagColors.danger : SwagColors.line,
              width: error != null ? 1.6 : 1.2,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: keyboardType,
                  obscureText: obscure,
                  style: SwagTheme.body(size: 14.5, weight: FontWeight.w600),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: SwagTheme.body(
                      size: 13.5,
                      color: SwagColors.inkFaint,
                    ),
                  ),
                ),
              ),
              if (trailing != null) ...[trailing!, const SizedBox(width: 14)],
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const SwagIcon('bolt', size: 12, color: SwagColors.danger),
                const SizedBox(width: 4),
                Text(
                  error!,
                  style: SwagTheme.body(
                    size: 11.5,
                    weight: FontWeight.w700,
                    color: SwagColors.danger,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
