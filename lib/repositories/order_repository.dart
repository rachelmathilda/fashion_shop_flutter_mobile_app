import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class OrderRepository {
  OrderRepository._();
  static final OrderRepository instance = OrderRepository._();

  final CollectionReference<Map<String, dynamic>> _col = FirebaseFirestore
      .instance
      .collection('orders');

  Future<String> createOrder(OrderModel order) async {
    final doc = await _col.add(order.toFirestore());
    return doc.id;
  }

  Stream<List<OrderModel>> watchByUserAndStatus(String userId, String status) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(OrderModel.fromFirestore).toList());
  }

  Future<List<OrderModel>> fetchByUserAndStatus(
    String userId,
    String status,
  ) async {
    final s = await _col
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .get();
    return s.docs.map(OrderModel.fromFirestore).toList();
  }

  Future<OrderModel?> fetchById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  Future<void> updateStatus(String id, String status) async {
    await _col.doc(id).update({'status': status});
  }

  Future<void> updatePaymentMethod(String id, String method) async {
    await _col.doc(id).update({'paymentMethod': method});
  }

  Future<void> updateAddress(String id, String address) async {
    await _col.doc(id).update({'address': address});
  }
}
