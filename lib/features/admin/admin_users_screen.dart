// =============================================================================
// File: lib/features/admin/admin_users_screen.dart
// Purpose: Admin user registry interface displaying registered shoppers and staff,
//          search by name/email, account status, and role inspection.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/swag_icon.dart';
import '../../data/models/user_profile.dart';
import '../../services/firestore_service.dart';
import '../../state/app_store.dart';

/// Screen allowing administrators to inspect registered user accounts, view addresses,
/// verify customer vs admin roles, and search by keyword.
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}


class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<UserProfile> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final current = context.read<SwagAppStore>().currentUser;
    setState(() => _isLoading = true);
    final users = await FirestoreService.instance.getAllUsers();

    // Ensure at least current user & demo user exist
    final all = List<UserProfile>.from(users);
    if (current != null && !all.any((u) => u.uid == current.uid)) {
      all.insert(0, current);
    }
    if (!all.any((u) => u.email == 'tejas@swagkart.in')) {
      all.add(
        UserProfile(
          uid: 'user-demo-1',
          name: 'Tejas Solanki',
          email: 'tejas@swagkart.in',
          phone: '+91 98765 43210',
          role: 'customer',
          street: '402, Phoenix Mills',
          city: 'Mumbai',
          pincode: '400013',
          state: 'Maharashtra',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      );
    }
    if (!all.any((u) => u.email == 'admin@swagkart.in')) {
      all.add(
        UserProfile(
          uid: 'admin-demo-1',
          name: 'Store Administrator',
          email: 'admin@swagkart.in',
          phone: '+91 99999 11111',
          role: 'admin',
          city: 'Mumbai',
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _users = all;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleRole(UserProfile user) async {
    final newRole = user.isAdmin ? 'customer' : 'admin';
    final updated = user.copyWith(role: newRole);
    await FirestoreService.instance.updateUser(updated);
    if (mounted) {
      setState(() {
        final idx = _users.indexWhere((u) => u.uid == user.uid);
        if (idx != -1) _users[idx] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} is now a $newRole.'),
          backgroundColor: SwagColors.ink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _users.where((u) {
      final q = _searchQuery.toLowerCase();
      return _searchQuery.isEmpty ||
          u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.role.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const SwagIcon('search', size: 16, color: SwagColors.canvas),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: SwagTheme.body(size: 13, color: SwagColors.canvas),
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search customers by name or email...',
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

        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: SwagColors.butter),
                )
              : filtered.isEmpty
              ? Center(
                  child: Text(
                    'No shoppers found.',
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
                    final u = filtered[index];
                    final isAdmin = u.isAdmin;
                    return Container(
                      padding: const EdgeInsets.all(14),
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
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isAdmin
                                    ? [SwagColors.accent, SwagColors.butter]
                                    : [
                                        SwagColors.lavenderDeep,
                                        SwagColors.mist,
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                u.initials,
                                style: SwagTheme.body(
                                  size: 14,
                                  weight: FontWeight.w800,
                                  color: isAdmin
                                      ? SwagColors.ink
                                      : SwagColors.canvas,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        u.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: SwagTheme.body(
                                          size: 14,
                                          weight: FontWeight.w800,
                                          color: SwagColors.canvas,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isAdmin
                                            ? SwagColors.accent.withValues(
                                                alpha: 0.25,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.1,
                                              ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        isAdmin ? 'ADMIN' : 'MEMBER',
                                        style: SwagTheme.body(
                                          size: 9.5,
                                          weight: FontWeight.w800,
                                          color: isAdmin
                                              ? SwagColors.accent
                                              : SwagColors.canvas.withValues(
                                                  alpha: 0.7,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  u.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: SwagTheme.body(
                                    size: 12,
                                    color: SwagColors.canvas.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                                if (u.phone.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    u.phone,
                                    style: SwagTheme.body(
                                      size: 11,
                                      color: SwagColors.canvas.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.08,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                            ),
                            onPressed: () => _toggleRole(u),
                            child: Text(
                              isAdmin ? 'Make Shopper' : 'Make Admin',
                              style: SwagTheme.body(
                                size: 11,
                                weight: FontWeight.w700,
                                color: isAdmin
                                    ? SwagColors.canvas.withValues(alpha: 0.7)
                                    : SwagColors.butter,
                              ),
                            ),
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
