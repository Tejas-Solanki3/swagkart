// =============================================================================
// File: lib/data/models/order.dart
// Purpose: Ecommerce order data model encapsulating purchased items, payment method,
//          transaction timestamps, pricing breakdown, and order status.
// =============================================================================

import 'cart_item.dart';

/// Supported checkout payment methods.
enum PayMethod { upi, card, cod }

/// A placed order record — kept for the success screen, account history,
/// and merchant admin order management.
class SwagOrder {
  SwagOrder({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    required this.method,
    required this.detail,
    required this.placedAt,
    this.status = 'Processing',
  });


  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double shipping;
  final double total;
  final PayMethod method;

  /// UPI id used, last-4 of card, or 'Cash on delivery'.
  final String detail;
  final DateTime placedAt;
  String status;

  String get methodLabel {
    switch (method) {
      case PayMethod.upi:
        return 'UPI';
      case PayMethod.card:
        return 'Card';
      case PayMethod.cod:
        return 'Cash on delivery';
    }
  }

  String get itemCount => '${items.fold(0, (s, i) => s + i.qty)} item(s)';
}
