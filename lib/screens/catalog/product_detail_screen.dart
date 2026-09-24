import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import '../../repositories/cart_repository.dart';
import '../../theme/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String _mainImage = widget.product.images.first;
  String? _selectedSize;
  bool _isAdding = false;

  Future<void> _addToCart() async {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih ukuran dulu')));
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan login dulu')));
      return;
    }

    setState(() => _isAdding = true);
    await CartRepository.instance.addItem(
      uid,
      CartItem(product: widget.product, selectedSize: _selectedSize!),
    );
    if (!mounted) return;
    setState(() => _isAdding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} ditambahkan ke keranjang'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 320,
                          width: double.infinity,
                          color: AppColors.cardBg,
                          child: Image.network(
                            _mainImage,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 60,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 16,
                          child: _circleButton(
                            icon: Icons.arrow_back,
                            onTap: () => context.pop(),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 16,
                          child: _circleButton(
                            icon: Icons.camera_alt_outlined,
                            onTap: () =>
                                context.push('/try-on', extra: product),
                          ),
                        ),
                        if (product.images.length > 1)
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 12,
                            child: SizedBox(
                              height: 60,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: product.images.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, i) {
                                  final img = product.images[i];
                                  final selected = img == _mainImage;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _mainImage = img),
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selected
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(
                                        img,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(color: AppColors.cardBg),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                '\$ ${product.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Product Details',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description.isNotEmpty
                                ? product.description
                                : 'Belum ada deskripsi untuk produk ini.',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Select Size',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: product.sizes
                                .map((s) => _sizeChip(s))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.primary,
                    ),
                    onPressed: () => context.push('/chat', extra: product),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isAdding ? null : _addToCart,
                      child: _isAdding
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  Widget _sizeChip(String label) {
    final selected = _selectedSize == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedSize = label),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.grey,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.white : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
