class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.blurb,
    required this.image,
    required this.price,
    this.mrp,
    required this.rating,
    required this.reviews,
    this.gallery = const [],
    this.colors = const [],
    this.sizes = const [],
    this.tags = const [],
    this.stock = 10,
  });

  final String id;
  final String name;
  final String brand;
  final String category; // id from SwagCategory
  final String blurb;
  final String image; // asset path
  final double price;
  final double? mrp;
  final double rating;
  final int reviews;
  final List<String> gallery;
  final List<String> colors; // hex strings
  final List<String> sizes;
  final List<String> tags; // trending | new | deal | bestseller
  final int stock;

  bool get onSale => mrp != null && mrp! > price;

  int get discountPct =>
      onSale ? ((mrp! - price) / mrp! * 100).round() : 0;

  double get savings => onSale ? mrp! - price : 0;

  List<String> get allImages {
    final imgs = [image];
    for (final g in gallery) {
      if (!imgs.contains(g)) imgs.add(g);
    }
    return imgs;
  }

  String get firstTag => tags.isEmpty ? '' : tags.first;
}
