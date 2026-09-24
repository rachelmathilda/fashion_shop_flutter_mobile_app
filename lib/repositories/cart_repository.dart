import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import 'product_repository.dart';

class CartRepository {
  CartRepository._();
  static final CartRepository instance = CartRepository._();

  CollectionReference<Map<String, dynamic>> _cartRef(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart');

  Stream<List<CartItem>> watchCart(String uid) {
    return _cartRef(uid).snapshots().asyncMap((snap) async {
      final items = <CartItem>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final productId = data['productId'] as String?;
        if (productId == null) continue;
        final product = await ProductRepository.instance.fetchById(productId);
        if (product == null) continue;
        items.add(
          CartItem(
            product: product,
            quantity: data['quantity'] ?? 1,
            selectedSize: data['selectedSize'] ?? 'M',
          ),
        );
      }
      return items;
    });
  }

  Future<void> addItem(String uid, CartItem item) async {
    await _cartRef(uid).doc(item.product.id).set(item.toFirestore());
  }

  Future<void> updateItem(
    String uid,
    String productId, {
    int? quantity,
    String? selectedSize,
  }) async {
    final data = <String, dynamic>{};
    if (quantity != null) data['quantity'] = quantity;
    if (selectedSize != null) data['selectedSize'] = selectedSize;
    if (data.isEmpty) return;
    await _cartRef(uid).doc(productId).update(data);
  }

  Future<void> removeItem(String uid, String productId) async {
    await _cartRef(uid).doc(productId).delete();
  }

  Future<void> clearCart(String uid) async {
    final snap = await _cartRef(uid).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
