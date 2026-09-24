import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  ChatRepository._();
  static final ChatRepository instance = ChatRepository._();

  CollectionReference<Map<String, dynamic>> _messagesRef(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chat_messages');

  Stream<List<ChatMessageModel>> watchMessages(String uid) {
    return _messagesRef(uid)
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map(ChatMessageModel.fromFirestore).toList());
  }

  Future<void> sendText(String uid, String text) async {
    await _messagesRef(uid).add(
      ChatMessageModel(
        id: '',
        text: text,
        isMe: true,
        createdAt: DateTime.now(),
      ).toFirestore(),
    );
  }

  Future<void> sendProductCard(
    String uid, {
    required String productId,
    required String productName,
    required String imageUrl,
  }) async {
    await _messagesRef(uid).add(
      ChatMessageModel(
        id: '',
        productId: productId,
        productName: productName,
        imageUrl: imageUrl,
        isMe: true,
        createdAt: DateTime.now(),
      ).toFirestore(),
    );
  }

  Future<bool> hasProductMessage(String uid, String productId) async {
    final snap = await _messagesRef(
      uid,
    ).where('productId', isEqualTo: productId).limit(1).get();
    return snap.docs.isNotEmpty;
  }
}
