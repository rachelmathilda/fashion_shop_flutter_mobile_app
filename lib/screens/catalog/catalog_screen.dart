import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';

final _catalogProducts = [
  ProductModel(id: '1', name: 'Sage Blouse', price: 20, imageUrl: '', rating: 4.5, sold: 10, category: 'Blouse', gender: 'Woman', sizes: ['S', 'M', 'L']),
  ProductModel(id: '2', name: 'Army Blouse', price: 20, imageUrl: '', rating: 4.5, sold: 10, category: 'Blouse', gender: 'Woman', sizes: ['S', 'M', 'L']),
  ProductModel(id: '3', name: 'Stripe Clothes', price: 20, imageUrl: '', rating: 4.5, sold: 10, category: 'Dress', gender: 'Woman', sizes: ['S', 'M', 'L']),
  ProductModel(id: '4', name: 'Denim Skirt', price: 20, imageUrl: '', rating: 4.5, sold: 10, category: 'Skirt', gender: 'Woman', sizes: ['S', 'M', 'L']),
  ProductModel(id: '5', name: 'Emerald Top', price: 20, imageUrl: '', rating: 4.5, sold: 10, category: 'Blouse', gender: 'Woman', sizes: ['S', 'M', 'L']),
  ProductModel(id: '6', name: 'Black Skirt', price: 30, imageUrl: '', rating: 4.0, sold: 10, category: 'Skirt', gender: 'Woman', sizes: ['S', 'M', 'L']),
];

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchCtrl = TextEditingController();

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
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.68,
                ),
                itemCount: _catalogProducts.length,
                itemBuilder: (context, i) => ProductCard(
                  product: _catalogProducts[i],
                  onTryOn: () => context.push('/try-on'),
                  onAddToCart: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
