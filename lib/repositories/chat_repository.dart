import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatRepository {
  ChatRepository._();
  static final ChatRepository instance = ChatRepository._();

  final CollectionReference<Map<String, dynamic>> _chats = FirebaseFirestore
      .instance
      .collection('chats');

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _chats.doc(chatId).collection('messages');

  Future<String> createChat(ChatModel chat) async {
    final doc = await _chats.add(chat.toFirestore());
    return doc.id;
  }

  Future<String?> findExistingChat(String userId, String? productId) async {
    final snap = await _chats
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id;
  }

  Stream<List<ChatMessageModel>> watchMessages(String chatId) {
    return _messages(chatId)
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map(ChatMessageModel.fromFirestore).toList());
  }

  Future<void> sendMessage(ChatMessageModel message) async {
    await _messages(message.chatId).add(message.toFirestore());
    await _chats.doc(message.chatId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ChatModel>> watchUserChats(String userId) {
    return _chats
        .where('userId', isEqualTo: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ChatModel.fromFirestore).toList());
  }
}
