import 'package:flutter_test/flutter_test.dart';
import 'package:swag_kart/data/models/product.dart';
import 'package:swag_kart/data/models/user_profile.dart';
import 'package:swag_kart/state/app_store.dart';

void main() {
  group('UserProfile Model', () {
    test('initials computation handles single and multi-word names', () {
      final user1 = UserProfile(
        uid: '1',
        name: 'Tejas Solanki',
        email: 'tejas@swagkart.in',
        createdAt: DateTime.now(),
      );
      expect(user1.initials, 'TS');
      expect(user1.isAdmin, isFalse);

      final user2 = UserProfile(
        uid: '2',
        name: 'Admin',
        email: 'admin@swagkart.in',
        role: 'admin',
        createdAt: DateTime.now(),
      );
      expect(user2.initials, 'A');
      expect(user2.isAdmin, isTrue);
    });

    test('address formatting handles partial and complete addresses', () {
      final user = UserProfile(
        uid: '1',
        name: 'Manas',
        email: 'manas@example.com',
        street: 'Flat 101, Sunshine Apts',
        city: 'Mumbai',
        pincode: '400050',
        state: 'Maharashtra',
        createdAt: DateTime.now(),
      );
      expect(
        user.formattedAddress,
        'Flat 101, Sunshine Apts, Mumbai, 400050, Maharashtra',
      );
    });
  });

  group('SwagAppStore Auth & Admin', () {
    test('demo shopper login and profile updates', () async {
      final store = SwagAppStore();
      expect(store.isLoggedIn, isFalse);

      await store.signInDemoCustomer();
      expect(store.isLoggedIn, isTrue);
      expect(store.currentUser?.name, 'Tejas Solanki');
      expect(store.isAdmin, isFalse);

      await store.updateProfile(
        name: 'Tejas S.',
        phone: '+91 99999 88888',
        street: 'Bandra West',
        city: 'Mumbai',
        pincode: '400050',
        state: 'Maharashtra',
      );
      expect(store.currentUser?.name, 'Tejas S.');
      expect(store.currentUser?.city, 'Mumbai');

      await store.logout();
      expect(store.isLoggedIn, isFalse);
      expect(store.currentUser, isNull);
    });

    test('demo admin login grants admin access', () async {
      final store = SwagAppStore();
      await store.signInDemoAdmin();
      expect(store.isLoggedIn, isTrue);
      expect(store.isAdmin, isTrue);
      await store.logout();
    });

    test('admin product addition and deletion', () {
      final store = SwagAppStore();
      final initialCount = store.products.length;

      const newDrop = Product(
        id: 'test-drop-1',
        name: 'Neon Oversized Hoodie',
        brand: 'Swag Original',
        category: 'streetwear',
        blurb: 'Test hoodie',
        image: 'assets/images/products/hoodie-black.png',
        price: 1999,
        rating: 5.0,
        reviews: 1,
      );

      store.addAdminProduct(newDrop);
      expect(store.products.length, initialCount + 1);
      expect(store.products.first.name, 'Neon Oversized Hoodie');

      store.deleteAdminProduct('test-drop-1');
      expect(store.products.length, initialCount);
    });
  });
}
