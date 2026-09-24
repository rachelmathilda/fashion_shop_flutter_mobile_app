import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final num price;
  final int quantity;
  final String selectedSize;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.selectedSize,
  });

  num get subtotal => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: data['price'] ?? 0,
      quantity: data['quantity'] ?? 1,
      selectedSize: data['selectedSize'] ?? 'M',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'selectedSize': selectedSize,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final num subtotal;
  final num discountAmount;
  final String? couponCode;
  final num deliveryFee;
  final num total;
  final String status;
  final String paymentMethod;
  final String addressText;
  final double? addressLat;
  final double? addressLng;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    this.couponCode,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.addressText,
    this.addressLat,
    this.addressLng,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      subtotal: data['subtotal'] ?? 0,
      discountAmount: data['discountAmount'] ?? 0,
      couponCode: data['couponCode'],
      deliveryFee: data['deliveryFee'] ?? 0,
      total: data['total'] ?? 0,
      status: data['status'] ?? 'processing',
      paymentMethod: data['paymentMethod'] ?? '',
      addressText: data['addressText'] ?? '',
      addressLat: (data['addressLat'] as num?)?.toDouble(),
      addressLng: (data['addressLng'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'couponCode': couponCode,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'addressText': addressText,
      'addressLat': addressLat,
      'addressLng': addressLng,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
