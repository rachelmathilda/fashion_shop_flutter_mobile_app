import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;
  final String code;
  final num percent;
  final num minTransaction;
  final String category;
  final DateTime validUntil;

  CouponModel({
    required this.id,
    required this.code,
    required this.percent,
    required this.minTransaction,
    required this.category,
    required this.validUntil,
  });

  bool get isExpired => DateTime.now().isAfter(validUntil);

  factory CouponModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return CouponModel(
      id: doc.id,
      code: data['code'] ?? doc.id,
      percent: data['percent'] ?? 0,
      minTransaction: data['minTransaction'] ?? 0,
      category: data['category'] ?? 'all',
      validUntil:
          (data['validUntil'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 1)),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'percent': percent,
      'minTransaction': minTransaction,
      'category': category,
      'validUntil': Timestamp.fromDate(validUntil),
    };
  }
}
