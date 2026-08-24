import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';

final _demoProducts = [
  ProductModel(
    id: '1',
    name: 'Blue Denim Dress',
    price: 30,
    imageUrl:
        'https://images.unsplash.com/photo-1594938298603-c8148c4b3b3b?w=400',
    rating: 4.5,
    sold: 10,
    category: 'Dress',
    gender: 'Woman',
    sizes: ['S', 'M', 'L'],
  ),
  ProductModel(
    id: '2',
    name: 'Navy Flower Dress',
    price: 20,
    imageUrl:
        'https://images.unsplash.com/photo-1591369822096-ffd140ec948f?w=400',
    rating: 4.5,
    sold: 10,
    category: 'Dress',
    gender: 'Woman',
    sizes: ['S', 'M', 'L'],
  ),
  ProductModel(
    id: '3',
    name: 'Denim Jumpsuit',
    price: 30,
    imageUrl:
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400',
    rating: 4.5,
    sold: 10,
    category: 'Jumpsuit',
    gender: 'Woman',
    sizes: ['S', 'M', 'L'],
  ),
  ProductModel(
    id: '4',
    name: 'Dark Denim Skirt',
    price: 30,
    imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
    rating: 4.5,
    sold: 10,
    category: 'Skirt',
    gender: 'Woman',
    sizes: ['S', 'M', 'L'],
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // AppBar: bell | Vaelys | chat — matches design exactly
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.primary,
          ),
          onPressed: () {},
        ),
        title: Text(
          'Vaelys',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner — full width model photo
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Image.network(
                'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.cardBg,
                  child: const Center(
                    child: Icon(
                      Icons.person_outline,
                      size: 80,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
            ),

            // Recommendation
            _sectionHeader(
              context,
              'Recommendation',
              () => context.go('/catalog'),
            ),
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 2,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 160,
                    child: ProductCard(
                      product: _demoProducts[i],
                      onTryOn: () => context.push('/try-on'),
                    ),
                  ),
                ),
              ),
            ),

            // Popular
            _sectionHeader(context, 'Popular', () => context.go('/catalog')),
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 2,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 160,
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

  Widget _sectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAll,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'see all',
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
