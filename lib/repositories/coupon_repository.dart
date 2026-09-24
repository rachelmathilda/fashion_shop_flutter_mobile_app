import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coupon_model.dart';

class CouponRepository {
  CouponRepository._();
  static final CouponRepository instance = CouponRepository._();

  final CollectionReference<Map<String, dynamic>> _col = FirebaseFirestore
      .instance
      .collection('coupons');

  Stream<List<CouponModel>> watchActive() {
    return _col.snapshots().map((s) {
      final coupons = s.docs.map(CouponModel.fromFirestore).toList();
      coupons.removeWhere((c) => c.isExpired);
      coupons.sort((a, b) => b.percent.compareTo(a.percent));
      return coupons;
    });
  }
}
