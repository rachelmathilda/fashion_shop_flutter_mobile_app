import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/cart_item_model.dart';
import '../../repositories/cart_repository.dart';
import '../../theme/app_theme.dart';

class BagScreen extends StatefulWidget {
  const BagScreen({super.key});

  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  final _cartRepository = CartRepository.instance;
  final Set<String> _selectedIds = {};

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  void _openEditSheet(CartItem item) {
    int quantity = item.quantity;
    String size = item.selectedSize;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const Text('Size'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: item.product.sizes.map((s) {
                        final selected = size == s;
                        return GestureDetector(
                          onTap: () => setSheetState(() => size = s),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.cardBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.white
                                      : AppColors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Quantity'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: quantity > 1
                              ? () => setSheetState(() => quantity--)
                              : null,
                        ),
                        Text(
                          '$quantity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setSheetState(() => quantity++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _cartRepository.removeItem(
                                _uid,
                                item.product.id,
                              );
                            },
                            child: const Text('Hapus'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _cartRepository.updateItem(
                                _uid,
                                item.product.id,
                                quantity: quantity,
                                selectedSize: size,
                              );
                            },
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Vaelys',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primary,
            ),
            onPressed: () => context.push('/chat'),
          ),
        ],
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: _cartRepository.watchCart(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Keranjang masih kosong'));
          }

          final selectedItems = items
              .where((i) => _selectedIds.contains(i.product.id))
              .toList();
          final total = selectedItems.fold<num>(
            0,
            (sum, i) => sum + i.subtotal,
          );

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.divider),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final selected = _selectedIds.contains(item.product.id);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              item.product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.checkroom_outlined,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$ ${item.product.price}',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  '${item.quantity} item, size ${item.selectedSize}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Checkbox(
                                value: selected,
                                activeColor: AppColors.primary,
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      _selectedIds.add(item.product.id);
                                    } else {
                                      _selectedIds.remove(item.product.id);
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                onPressed: () => _openEditSheet(item),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: ElevatedButton(
                  onPressed: selectedItems.isEmpty
                      ? null
                      : () => context.push('/order', extra: selectedItems),
                  child: Text(
                    selectedItems.isEmpty
                        ? 'Checkout'
                        : 'Checkout (\$ ${total.toStringAsFixed(2)})',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
