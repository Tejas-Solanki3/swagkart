// =============================================================================
// File: lib/data/models/cart_item.dart
// Purpose: Shopping cart item data model tracking selected product, size,
//          color variant, quantity, unique item key, and subtotal calculation.
// =============================================================================

import 'product.dart';

/// Represents a single product configuration in the customer's shopping bag.
class CartItem {
  CartItem({
    required this.product,
    required this.size,
    required this.color,
    this.qty = 1,
  });

  /// The underlying product details
  final Product product;

  /// Selected size (e.g. 'M', 'L', 'UK 9')
  final String size;

  /// Selected color hex code or name
  final String color;

  /// Number of units in cart
  int qty;

  /// Unique composite identifier combining product ID, size, and color.
  String get key => keyFor(product.id, size, color);

  /// Helper generating unique keys for cart lookups.
  static String keyFor(String productId, String size, String color) =>
      '$productId|$size|$color';

  /// Total price for this line item (price * quantity).
  double get lineTotal => product.price * qty;
}

