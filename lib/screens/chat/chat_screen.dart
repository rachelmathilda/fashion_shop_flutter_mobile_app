import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/chat_message_model.dart';
import '../../models/product_model.dart';
import '../../repositories/chat_repository.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.product});

  final ProductModel? product;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatRepository = ChatRepository.instance;
  final _msgCtrl = TextEditingController();

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _seedProductMessage();
  }

  Future<void> _seedProductMessage() async {
    final product = widget.product;
    if (product == null) return;
    final already = await _chatRepository.hasProductMessage(_uid, product.id);
    if (already) return;
    await _chatRepository.sendProductCard(
      _uid,
      productId: product.id,
      productName: product.name,
      imageUrl: product.imageUrl,
    );
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _chatRepository.sendText(_uid, text);
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Chat',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: _chatRepository.watchMessages(_uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Mulai percakapan dengan toko'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];

                    if (msg.imageUrl != null) {
                      return Align(
                        alignment: msg.isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: msg.isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                msg.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.checkroom_outlined,
                                  color: AppColors.grey,
                                  size: 50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Align(
                      alignment: msg.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: msg.isMe ? AppColors.cardBg : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg.text ?? '',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(
                hintText: 'Ask us anything about the clothes',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _send,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
