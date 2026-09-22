import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import '../../repositories/cart_repository.dart';
import '../../repositories/product_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchCtrl = TextEditingController();
  final _productRepository = ProductRepository.instance;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _addToCart(ProductModel product) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan login dulu')));
      return;
    }
    await CartRepository.instance.addItem(
      uid,
      CartItem(
        product: product,
        selectedSize: product.sizes.isNotEmpty ? product.sizes.first : 'M',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} ditambahkan ke keranjang')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, color: AppColors.primary),
                    onPressed: () => context.push('/filter'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: _productRepository.watchAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Gagal memuat produk'));
                  }
                  var products = snapshot.data ?? [];
                  if (_query.isNotEmpty) {
                    products = products
                        .where((p) => p.name.toLowerCase().contains(_query))
                        .toList();
                  }
                  if (products.isEmpty) {
                    return const Center(child: Text('Produk tidak ditemukan'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.68,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, i) => ProductCard(
                      product: products[i],
                      onTap: () =>
                          context.push('/product-detail', extra: products[i]),
                      onTryOn: () =>
                          context.push('/try-on', extra: products[i]),
                      onAddToCart: () => _addToCart(products[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
