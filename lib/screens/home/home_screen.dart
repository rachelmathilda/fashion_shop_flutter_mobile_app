import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';

final _demoProducts = [
  ProductModel(id: '1', name: 'Blue Denim Dress', price: 30, imageUrl: '', rating: 4.5, sold: 10, category: 'Dress', gender: 'Woman', sizes: ['S', 'M', 'L']),
  ProductModel(id: '2', name: 'Navy Flower Dress', price: 20, imageUrl: '', rating: 4.5, sold: 10, category: 'Dress', gender: 'Woman', sizes: ['S', 'M', 'L']),
  ProductModel(id: '3', name: 'Denim Jumpsuit', price: 30, imageUrl: '', rating: 4.5, sold: 10, category: 'Jumpsuit', gender: 'Woman', sizes: ['S', 'M', 'L']),
  ProductModel(id: '4', name: 'Dark Denim Skirt', price: 30, imageUrl: '', rating: 4.5, sold: 10, category: 'Skirt', gender: 'Woman', sizes: ['S', 'M', 'L']),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  color: AppColors.cardBg,
                  child: const Center(
                    child: Icon(Icons.person_outline,
                        size: 100, color: AppColors.grey),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Vaelys',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: AppColors.primary)),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline,
                              color: AppColors.primary),
                          onPressed: () => context.push('/chat'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Recommendation
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recommendation',
                      style: Theme.of(context).textTheme.headlineSmall),
                  GestureDetector(
                    onTap: () => context.go('/catalog'),
                    child: const Text('see all',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontFamily: 'Inter',
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 2,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: SizedBox(
                    width: 150,
                    child: ProductCard(
                      product: _demoProducts[i],
                      onTryOn: () => context.push('/try-on'),
                    ),
                  ),
                ),
              ),
            ),
            // Popular
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Popular',
                      style: Theme.of(context).textTheme.headlineSmall),
                  GestureDetector(
                    onTap: () => context.go('/catalog'),
                    child: const Text('see all',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontFamily: 'Inter',
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 2,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: SizedBox(
                    width: 150,
                    child: ProductCard(
                      product: _demoProducts[i + 2],
                      onTryOn: () => context.push('/try-on'),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
