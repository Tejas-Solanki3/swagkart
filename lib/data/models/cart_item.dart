import 'product.dart';

class CartItem {
  CartItem({
    required this.product,
    required this.size,
    required this.color,
    this.qty = 1,
  });

  final Product product;
  final String size;
  final String color;
  int qty;

  String get key => keyFor(product.id, size, color);

  static String keyFor(String productId, String size, String color) =>
      '$productId|$size|$color';

  double get lineTotal => product.price * qty;
}
