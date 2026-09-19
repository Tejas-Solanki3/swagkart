// =============================================================================
// File: lib/features/admin/admin_orders_screen.dart
// Purpose: Admin order management interface for filtering orders by status
//          (Placed, Processing, Shipped, Delivered) and updating delivery tracking.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/chip.dart';
import '../../core/widgets/swag_icon.dart';
import '../../state/app_store.dart';

/// Screen allowing store administrators to inspect customer orders, view line
/// items, filter by fulfillment stage, and update order statuses.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}


class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SwagAppStore>().loadAdminOrders();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return SwagColors.mint;
      case 'shipped':
        return SwagColors.lavender;
      case 'processing':
        return SwagColors.butter;
      case 'placed':
      default:
        return SwagColors.peach;
    }
  }

  void _changeStatus(String orderId, String currentStatus) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF242330),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Order Status: $orderId',
              style: SwagTheme.display(size: 18, color: SwagColors.canvas),
            ),
            const SizedBox(height: 16),
            for (final status in [
              'Placed',
              'Processing',
              'Shipped',
              'Delivered',
            ])
              ListTile(
                title: Text(
                  status,
                  style: SwagTheme.body(
                    size: 14,
                    weight: FontWeight.w700,
                    color: currentStatus == status
                        ? SwagColors.butter
                        : SwagColors.canvas,
                  ),
                ),
                trailing: currentStatus == status
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: SwagColors.butter,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  context.read<SwagAppStore>().updateOrderStatus(
                    orderId,
                    status,
                  );
                  Navigator.of(sheetCtx).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SwagAppStore>();
    final orders = store.allOrders;

    final filtered = orders.where((o) {
      if (_selectedFilter == 'All') return true;
      return o.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Column(
      children: [
        // Status filter strip
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final filter in [
                'All',
                'Placed',
                'Processing',
                'Shipped',
                'Delivered',
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AdminChip(
                    label: filter,
                    selected: _selectedFilter == filter,
                    badge: filter == 'All'
                        ? '${orders.length}'
                        : '${orders.where((o) => o.status.toLowerCase() == filter.toLowerCase()).length}',
                    onTap: () => setState(() => _selectedFilter = filter),
                  ),
                ),
            ],
          ),
        ),

        // Orders list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SwagIcon(
                        'package',
                        size: 36,
                        color: SwagColors.inkFaint,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No orders in this status category.',
                        style: SwagTheme.body(
                          size: 13,
                          color: SwagColors.canvas.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    final color = _statusColor(order.status);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.09),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.id,
                                style: SwagTheme.body(
                                  size: 14.5,
                                  weight: FontWeight.w800,
                                  color: SwagColors.canvas,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _changeStatus(order.id, order.status),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        order.status,
                                        style: SwagTheme.body(
                                          size: 11,
                                          weight: FontWeight.w800,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: color,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Placed: ${order.placedAt.day}/${order.placedAt.month}/${order.placedAt.year} · ${order.methodLabel}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: SwagTheme.body(
                                        size: 12,
                                        color: SwagColors.canvas.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    if (order.items.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '${order.items.length} item(s): ${order.items.map((e) => e.product.name).take(2).join(', ')}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: SwagTheme.body(
                                          size: 11.5,
                                          color: SwagColors.canvas.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                inr(order.total),
                                style: SwagTheme.body(
                                  size: 15,
                                  weight: FontWeight.w900,
                                  color: SwagColors.butter,
                                ),
                              ),
                            ],
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
