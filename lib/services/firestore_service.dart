// =============================================================================
// File: lib/services/firestore_service.dart
// Purpose: Cloud Firestore database service providing CRUD operations for users,
//          orders, and products with local in-memory fallback stores.
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models/order.dart';
import '../data/models/user_profile.dart';
import 'firebase_service.dart';

/// Singleton service interfacing with Cloud Firestore collections:
/// `users` and `orders`.
class FirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Local fallback storage when Firebase is not connected
  final Map<String, UserProfile> _localUsers = {};
  final List<SwagOrder> _localOrders = [];

  // ============================================================== USERS
  Future<UserProfile?> getUser(String uid) async {

    if (!FirebaseService.isInitialized) {
      return _localUsers[uid];
    }
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!, id: doc.id);
      }
    } catch (e) {
      if (kDebugMode) print('Firestore getUser error: $e');
    }
    return _localUsers[uid];
  }

  Future<void> saveUser(UserProfile profile) async {
    _localUsers[profile.uid] = profile;
    if (!FirebaseService.isInitialized) return;
    try {
      await _db
          .collection('users')
          .doc(profile.uid)
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('Firestore saveUser error: $e');
    }
  }

  Future<void> updateUser(UserProfile profile) async {
    _localUsers[profile.uid] = profile;
    if (!FirebaseService.isInitialized) return;
    try {
      await _db.collection('users').doc(profile.uid).update(profile.toMap());
    } catch (e) {
      if (kDebugMode) print('Firestore updateUser error: $e');
    }
  }

  Future<List<UserProfile>> getAllUsers() async {
    if (!FirebaseService.isInitialized) {
      return _localUsers.values.toList();
    }
    try {
      final snapshot = await _db.collection('users').get();
      final users = snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data(), id: doc.id))
          .toList();
      for (final u in users) {
        _localUsers[u.uid] = u;
      }
      return users;
    } catch (e) {
      if (kDebugMode) print('Firestore getAllUsers error: $e');
      return _localUsers.values.toList();
    }
  }

  // ============================================================== ORDERS
  Future<void> saveOrder(
    SwagOrder order, {
    String? userId,
    String? userEmail,
  }) async {
    _localOrders.insert(0, order);
    if (!FirebaseService.isInitialized) return;
    try {
      await _db.collection('orders').doc(order.id).set({
        'id': order.id,
        'userId': userId ?? 'guest',
        'userEmail': userEmail ?? 'guest@swagkart.in',
        'subtotal': order.subtotal,
        'discount': order.discount,
        'shipping': order.shipping,
        'total': order.total,
        'method': order.method.name,
        'detail': order.detail,
        'status': order.status,
        'placedAt': order.placedAt.toIso8601String(),
        'items': order.items
            .map(
              (i) => {
                'productId': i.product.id,
                'name': i.product.name,
                'price': i.product.price,
                'size': i.size,
                'color': i.color,
                'qty': i.qty,
              },
            )
            .toList(),
      });
    } catch (e) {
      if (kDebugMode) print('Firestore saveOrder error: $e');
    }
  }

  Future<List<SwagOrder>> getAllOrders() async {
    if (!FirebaseService.isInitialized) {
      return List.unmodifiable(_localOrders);
    }
    try {
      final snapshot = await _db
          .collection('orders')
          .orderBy('placedAt', descending: true)
          .get();

      final orders = <SwagOrder>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        orders.add(
          SwagOrder(
            id: data['id'] as String? ?? doc.id,
            items: const [], // Summary view for orders table
            subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
            discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
            shipping: (data['shipping'] as num?)?.toDouble() ?? 0.0,
            total: (data['total'] as num?)?.toDouble() ?? 0.0,
            method: _parsePayMethod(data['method'] as String?),
            detail: (data['detail'] as String?) ?? '',
            placedAt: data['placedAt'] != null
                ? DateTime.tryParse(data['placedAt'].toString()) ??
                      DateTime.now()
                : DateTime.now(),
            status: (data['status'] as String?) ?? 'Processing',
          ),
        );
      }
      return orders.isNotEmpty ? orders : _localOrders;
    } catch (e) {
      if (kDebugMode) print('Firestore getAllOrders error: $e');
      return List.unmodifiable(_localOrders);
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    for (final o in _localOrders) {
      if (o.id == orderId) {
        o.status = newStatus;
        break;
      }
    }
    if (!FirebaseService.isInitialized) return;
    try {
      await _db.collection('orders').doc(orderId).update({'status': newStatus});
    } catch (e) {
      if (kDebugMode) print('Firestore updateOrderStatus error: $e');
    }
  }

  static PayMethod _parsePayMethod(String? str) {
    if (str == 'upi') return PayMethod.upi;
    if (str == 'card') return PayMethod.card;
    return PayMethod.cod;
  }
}
