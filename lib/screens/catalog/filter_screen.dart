import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/product_model.dart';
import '../../repositories/product_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _productRepository = ProductRepository.instance;
  final _searchCtrl = TextEditingController();

  String _gender = 'All';
  String _clothesType = 'All';
  String _size = 'All Size';
  String _query = '';

  final _genders = ['All', 'Woman', 'Man'];
  final _types = ['All', 'Blouse', 'Dress', 'Skirt', 'Jumpsuit', 'Shirt'];
  final _sizes = ['S', 'M', 'L', 'XL', 'XXL', 'All Size'];

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

  List<ProductModel> _applyFilters(List<ProductModel> products) {
    return products.where((p) {
      final matchGender = _gender == 'All' || p.gender == _gender;
      final matchType = _clothesType == 'All' || p.category == _clothesType;
      final matchSize = _size == 'All Size' || p.sizes.contains(_size);
      final matchQuery =
          _query.isEmpty || p.name.toLowerCase().contains(_query);
      return matchGender && matchType && matchSize && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search, color: AppColors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _productRepository.watchAll(),
        builder: (context, snapshot) {
          final allProducts = snapshot.data ?? [];
          final filtered = _applyFilters(allProducts);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Gender'),
                const SizedBox(height: 10),
                Row(
                  children: _genders
                      .map(
                        (g) => Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: g,
                                groupValue: _gender,
                                activeColor: AppColors.primary,
                                onChanged: (v) => setState(() => _gender = v!),
                              ),
                              Text(
                                g,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Clothes Type'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _types.map((t) => _typeChip(t)).toList(),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Size'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _sizes.map((s) => _sizeChip(s)).toList(),
                ),
                const SizedBox(height: 32),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('Produk tidak ditemukan'),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.68,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => ProductCard(
                      product: filtered[i],
                      onTap: () =>
                          context.push('/product-detail', extra: filtered[i]),
                      onTryOn: () =>
                          context.push('/try-on', extra: filtered[i]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) =>
      Text(title, style: Theme.of(context).textTheme.titleLarge);

  Widget _typeChip(String label) {
    final selected = _clothesType == label;
    return GestureDetector(
      onTap: () => setState(() => _clothesType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
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
    );
  }

  Widget _sizeChip(String label) {
    final selected = _size == label;
    return GestureDetector(
      onTap: () => setState(() => _size = label),
      child: Container(
        width: label == 'All Size' ? 80 : 50,
        height: 50,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
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
