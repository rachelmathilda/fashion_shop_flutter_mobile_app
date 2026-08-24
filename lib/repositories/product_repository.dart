import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  ProductRepository._();
  static final ProductRepository instance = ProductRepository._();

  final CollectionReference<Map<String, dynamic>> _col = FirebaseFirestore
      .instance
      .collection('products');

  Stream<List<ProductModel>> watchAll() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ProductModel.fromFirestore).toList());
  }

  Future<List<ProductModel>> fetchAll() async {
    final s = await _col.orderBy('createdAt', descending: true).get();
    return s.docs.map(ProductModel.fromFirestore).toList();
  }

  Future<List<ProductModel>> fetchByCategory(String category) async {
    final s = await _col.where('category', isEqualTo: category).get();
    return s.docs.map(ProductModel.fromFirestore).toList();
  }

  Future<List<ProductModel>> fetchPopular({int limit = 10}) async {
    final s = await _col.orderBy('sold', descending: true).limit(limit).get();
    return s.docs.map(ProductModel.fromFirestore).toList();
  }

  Future<ProductModel?> fetchById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }

  Future<String> create(ProductModel product) async {
    final doc = await _col.add(product.toFirestore());
    return doc.id;
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> incrementSold(String id, int by) async {
    await _col.doc(id).update({'sold': FieldValue.increment(by)});
  }
}
