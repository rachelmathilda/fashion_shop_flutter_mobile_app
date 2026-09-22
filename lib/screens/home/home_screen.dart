import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../repositories/product_repository.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _productRepository = ProductRepository.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
            _sectionHeader(
              context,
              'Recommendation',
              () => context.go('/catalog'),
            ),
            _horizontalProductList(_productRepository.watchRecommended()),
            _sectionHeader(context, 'Popular', () => context.go('/catalog')),
            _horizontalProductList(_productRepository.watchPopular()),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _horizontalProductList(Stream<List<ProductModel>> stream) {
    return SizedBox(
      height: 230,
      child: StreamBuilder<List<ProductModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat produk'));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('Belum ada produk'));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 160,
                child: ProductCard(
                  product: products[i],
                  onTap: () =>
                      context.push('/product-detail', extra: products[i]),
                  onTryOn: () => context.push('/try-on', extra: products[i]),
                ),
              ),
            ),
          );
        },
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
