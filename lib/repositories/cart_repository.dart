import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class CartRepository {
  CartRepository._();
  static final CartRepository instance = CartRepository._();

  CollectionReference<Map<String, dynamic>> _cartRef(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart');

  Stream<List<CartItem>> watchCart(
    String uid, {
    required ProductModel Function(Map<String, dynamic> data) productBuilder,
  }) {
    return _cartRef(uid).snapshots().map(
      (snap) => snap.docs.map((doc) {
        final data = doc.data();
        return CartItem(
          product: productBuilder(data),
          quantity: data['quantity'] ?? 1,
          selectedSize: data['selectedSize'] ?? 'M',
        );
      }).toList(),
    );
  }

  Future<void> addItem(String uid, CartItem item) async {
    await _cartRef(uid).doc(item.product.id).set(item.toFirestore());
  }

  Future<void> updateQuantity(
    String uid,
    String productId,
    int quantity,
  ) async {
    await _cartRef(uid).doc(productId).update({'quantity': quantity});
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
