import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String? text;
  final String? imageUrl;
  final String? productId;
  final String? productName;
  final bool isMe;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    this.text,
    this.imageUrl,
    this.productId,
    this.productName,
    required this.isMe,
    required this.createdAt,
  });

  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ChatMessageModel(
      id: doc.id,
      text: data['text'],
      imageUrl: data['imageUrl'],
      productId: data['productId'],
      productName: data['productName'],
      isMe: data['isMe'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'imageUrl': imageUrl,
      'productId': productId,
      'productName': productName,
      'isMe': isMe,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
