import 'package:flutter_test/flutter_test.dart';
import 'package:swag_kart/state/app_store.dart';

void main() {
  final store = SwagAppStore();

  test('plurals are flexible', () {
    expect(store.search('sneakers'), isNotEmpty);
    expect(store.search('sneaker'), isNotEmpty);
    expect(store.search('hoodies'), isNotEmpty);
    expect(store.search('hoodie'), isNotEmpty);
    expect(store.search('caps'), isNotEmpty);
    expect(store.search('cap'), isNotEmpty);
  });

  test('shoe synonyms match footwear products', () {
    final shoes = store.search('shoes');
    final shoe = store.search('shoe');
    expect(shoes, isNotEmpty);
    expect(shoe, isNotEmpty);
    // Every "shoe" result is footwear.
    for (final p in shoes) {
      expect(p.category, 'footwear');
    }
  });

  test('multi-word and junk queries behave sensibly', () {
    expect(store.search('oversized hoodie'), isNotEmpty);
    // Blank query = show everything (search screen default state).
    expect(store.search('   '), hasLength(store.products.length));
    expect(store.search('qqqzzz'), isEmpty);
  });
}
