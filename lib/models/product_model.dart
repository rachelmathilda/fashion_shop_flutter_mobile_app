import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final num price;
  final String imageUrl;
  final List<String> images;
  final String description;
  final double rating;
  final int sold;
  final String category;
  final String gender;
  final List<String> sizes;
  final bool isRecommended;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    List<String>? images,
    this.description = '',
    required this.rating,
    required this.sold,
    required this.category,
    required this.gender,
    required this.sizes,
    this.isRecommended = false,
  }) : images = (images == null || images.isEmpty) ? [imageUrl] : images;

  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      sold: data['sold'] ?? 0,
      category: data['category'] ?? '',
      gender: data['gender'] ?? '',
      sizes: List<String>.from(data['sizes'] ?? []),
      isRecommended: data['isRecommended'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'images': images,
      'description': description,
      'rating': rating,
      'sold': sold,
      'category': category,
      'gender': gender,
      'sizes': sizes,
      'isRecommended': isRecommended,
    };
  }
}
