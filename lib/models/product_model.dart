import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final double rating;
  final int sold;
  final String category;
  final String gender;
  final List<String> sizes;
  final String? description;
  final int stock;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.sold,
    required this.category,
    required this.gender,
    required this.sizes,
    this.description,
    this.stock = 0,
    this.createdAt,
  });

  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return ProductModel(
      id: doc.id,
      name: d['name'] ?? '',
      price: (d['price'] ?? 0).toDouble(),
      imageUrl: d['imageUrl'] ?? '',
      rating: (d['rating'] ?? 0).toDouble(),
      sold: d['sold'] ?? 0,
      category: d['category'] ?? '',
      gender: d['gender'] ?? 'All',
      sizes: List<String>.from(d['sizes'] ?? []),
      description: d['description'],
      stock: d['stock'] ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'rating': rating,
    'sold': sold,
    'category': category,
    'gender': gender,
    'sizes': sizes,
    'description': description,
    'stock': stock,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };
}

class CartItem {
  final ProductModel product;
  int quantity;
  String selectedSize;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.selectedSize,
  });

  double get total => product.price * quantity;

  Map<String, dynamic> toFirestore() => {
    'productId': product.id,
    'productName': product.name,
    'productPrice': product.price,
    'productImage': product.imageUrl,
    'quantity': quantity,
    'selectedSize': selectedSize,
  };
}

class OrderModel {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final double discountFee;
  final double deliveryFee;
  final double finalPrice;
  final String status;
  final String? address;
  final String? paymentMethod;
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.discountFee,
    required this.deliveryFee,
    required this.finalPrice,
    required this.status,
    this.address,
    this.paymentMethod,
    this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return OrderModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      items: List<Map<String, dynamic>>.from(d['items'] ?? []),
      totalPrice: (d['totalPrice'] ?? 0).toDouble(),
      discountFee: (d['discountFee'] ?? 0).toDouble(),
      deliveryFee: (d['deliveryFee'] ?? 0).toDouble(),
      finalPrice: (d['finalPrice'] ?? 0).toDouble(),
      status: d['status'] ?? 'need_to_pay',
      address: d['address'],
      paymentMethod: d['paymentMethod'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'items': items,
    'totalPrice': totalPrice,
    'discountFee': discountFee,
    'deliveryFee': deliveryFee,
    'finalPrice': finalPrice,
    'status': status,
    'address': address,
    'paymentMethod': paymentMethod,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };
}
