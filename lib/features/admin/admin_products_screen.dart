// =============================================================================
// File: lib/features/admin/admin_products_screen.dart
// Purpose: Admin inventory management screen allowing real-time searching,
//          stock updates, deletion, and creating new streetwear product drops.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/chip.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swag_button.dart';
import '../../core/widgets/swag_icon.dart';
import '../../data/models/product.dart';
import '../../state/app_store.dart';

/// Screen allowing merchants to view catalog inventory, search items,
/// filter by product category, delete items, and launch new drops via a creation dialog.
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}


class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';

  void _showAddProductDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final brandCtrl = TextEditingController(text: 'Swag Original');
    final priceCtrl = TextEditingController();
    final mrpCtrl = TextEditingController();
    final blurbCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '25');
    String category = 'streetwear';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF242330),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Streetwear Drop',
                          style: SwagTheme.display(
                            size: 20,
                            color: SwagColors.canvas,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: SwagColors.inkFaint,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _darkField(
                      controller: nameCtrl,
                      label: 'Product Name',
                      hint: 'e.g. Acid Wash Oversized Tee',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _darkField(
                            controller: brandCtrl,
                            label: 'Brand',
                            hint: 'Brand name',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category',
                                style: SwagTheme.body(
                                  size: 11.5,
                                  weight: FontWeight.w700,
                                  color: SwagColors.canvas.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: category,
                                    dropdownColor: const Color(0xFF242330),
                                    style: SwagTheme.body(
                                      size: 13,
                                      color: SwagColors.canvas,
                                    ),
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'streetwear',
                                        child: Text('Streetwear'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'footwear',
                                        child: Text('Footwear'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'denim',
                                        child: Text('Denim'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'accessories',
                                        child: Text('Accessories'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'winter',
                                        child: Text('Winter'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setDialogState(() => category = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _darkField(
                            controller: priceCtrl,
                            label: 'Price (₹)',
                            hint: '1499',
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v == null || double.tryParse(v) == null
                                ? 'Invalid price'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _darkField(
                            controller: mrpCtrl,
                            label: 'MRP (₹)',
                            hint: '2499',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _darkField(
                            controller: stockCtrl,
                            label: 'Stock Qty',
                            hint: '25',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _darkField(
                      controller: blurbCtrl,
                      label: 'Short Description',
                      hint: 'Streetwear staple with 340 GSM heavy cotton.',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    SwagButton(
                      label: 'Add to Storefront',
                      icon: 'sparkles',
                      background: SwagColors.accent,
                      foreground: SwagColors.ink,
                      height: 48,
                      onTap: () {
                        if (!formKey.currentState!.validate()) return;
                        final price = double.parse(priceCtrl.text.trim());
                        final mrp =
                            double.tryParse(mrpCtrl.text.trim()) ??
                            (price * 1.3);
                        final stock = int.tryParse(stockCtrl.text.trim()) ?? 20;

                        final newProduct = Product(
                          id: 'drop-${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          brand: brandCtrl.text.trim().isEmpty
                              ? 'Swag Original'
                              : brandCtrl.text.trim(),
                          category: category,
                          blurb: blurbCtrl.text.trim().isEmpty
                              ? 'Limited streetwear drop. Premium cotton build.'
                              : blurbCtrl.text.trim(),
                          image: 'assets/images/products/hoodie-black.png',
                          price: price,
                          mrp: mrp,
                          rating: 4.8,
                          reviews: 1,
                          tags: ['new', 'trending'],
                          stock: stock,
                          sizes: const ['S', 'M', 'L', 'XL'],
                          colors: const ['#1C1B24', '#F1F0F6', '#FF6B4A'],
                        );

                        context.read<SwagAppStore>().addAdminProduct(
                          newProduct,
                        );
                        Navigator.of(dialogCtx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '"${newProduct.name}" added to SwagKart catalog!',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _darkField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SwagTheme.body(
            size: 11.5,
            weight: FontWeight.w700,
            color: SwagColors.canvas.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: SwagTheme.body(size: 13, color: SwagColors.canvas),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: SwagTheme.body(
              size: 12.5,
              color: SwagColors.canvas.withValues(alpha: 0.3),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: SwagColors.accent),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SwagAppStore>();
    final all = store.products;

    final filtered = all.where((p) {
      final matchesCat =
          _selectedCategory == 'all' || p.category == _selectedCategory;
      final matchesQuery =
          _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.brand.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();

    return Column(
      children: [
        // Top control strip
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const SwagIcon(
                        'search',
                        size: 16,
                        color: SwagColors.canvas,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          style: SwagTheme.body(
                            size: 13,
                            color: SwagColors.canvas,
                          ),
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: SwagTheme.body(
                              size: 12.5,
                              color: SwagColors.canvas.withValues(alpha: 0.4),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Pressable(
                onTap: _showAddProductDialog,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: SwagColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: SwagColors.ink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Add Drop',
                        style: SwagTheme.body(
                          size: 12.5,
                          weight: FontWeight.w800,
                          color: SwagColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Category filter chips
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final cat in [
                'all',
                'streetwear',
                'footwear',
                'denim',
                'accessories',
                'winter',
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AdminChip(
                    label: cat[0].toUpperCase() + cat.substring(1),
                    selected: _selectedCategory == cat,
                    badge: cat == 'all'
                        ? '${store.products.length}'
                        : '${store.products.where((p) => p.category.toLowerCase() == cat).length}',
                    onTap: () => setState(() => _selectedCategory = cat),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Product list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No products match your filters.',
                    style: SwagTheme.body(
                      size: 13,
                      color: SwagColors.canvas.withValues(alpha: 0.5),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.09),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                p.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Center(
                                  child: SwagIcon(
                                    'bag',
                                    size: 22,
                                    color: SwagColors.canvas,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: SwagTheme.body(
                                    size: 14,
                                    weight: FontWeight.w700,
                                    color: SwagColors.canvas,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.brand} · ${p.category} · Stock: ${p.stock}',
                                  style: SwagTheme.body(
                                    size: 11.5,
                                    color: SwagColors.canvas.withValues(
                                      alpha: 0.55,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      inr(p.price),
                                      style: SwagTheme.body(
                                        size: 13,
                                        weight: FontWeight.w800,
                                        color: SwagColors.butter,
                                      ),
                                    ),
                                    if (p.onSale) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        inr(p.mrp!),
                                        style: TextStyle(
                                          fontSize: 11,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: SwagColors.canvas.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: SwagColors.accent,
                              size: 20,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (dlg) => AlertDialog(
                                  backgroundColor: const Color(0xFF242330),
                                  title: Text(
                                    'Delete Product?',
                                    style: SwagTheme.display(
                                      size: 18,
                                      color: SwagColors.canvas,
                                    ),
                                  ),
                                  content: Text(
                                    'Remove "${p.name}" from catalog?',
                                    style: SwagTheme.body(
                                      size: 13,
                                      color: SwagColors.canvas.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(dlg).pop(),
                                      child: Text(
                                        'Cancel',
                                        style: SwagTheme.body(
                                          size: 13,
                                          color: SwagColors.canvas.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: SwagColors.accent,
                                      ),
                                      onPressed: () {
                                        store.deleteAdminProduct(p.id);
                                        Navigator.of(dlg).pop();
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: SwagColors.ink,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
