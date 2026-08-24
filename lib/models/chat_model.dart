import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String userId;
  final String? productId;
  final String? productName;
  final String? productImage;
  final DateTime? lastMessageAt;

  const ChatModel({
    required this.id,
    required this.userId,
    this.productId,
    this.productName,
    this.productImage,
    this.lastMessageAt,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ChatModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      productId: d['productId'],
      productName: d['productName'],
      productImage: d['productImage'],
      lastMessageAt: (d['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'productId': productId,
    'productName': productName,
    'productImage': productImage,
    'lastMessageAt': FieldValue.serverTimestamp(),
  };
}

class ChatMessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final bool isFromShop;
  final String? text;
  final String? imageUrl;
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.isFromShop,
    this.text,
    this.imageUrl,
    this.createdAt,
  });

  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return ChatMessageModel(
      id: doc.id,
      chatId: d['chatId'] ?? '',
      senderId: d['senderId'] ?? '',
      isFromShop: d['isFromShop'] ?? false,
      text: d['text'],
      imageUrl: d['imageUrl'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'chatId': chatId,
    'senderId': senderId,
    'isFromShop': isFromShop,
    'text': text,
    'imageUrl': imageUrl,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };
}
