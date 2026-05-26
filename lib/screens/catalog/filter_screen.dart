import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String _gender = 'All';
  String _clothesType = 'All';
  String _size = 'All Size';

  final _genders = ['All', 'Woman', 'Man'];
  final _types = ['All', 'Blouse', 'Dress', 'Skirt', 'Jumpsuit', 'Shirt'];
  final _sizes = ['S', 'M', 'L', 'XL', 'XXL', 'All Size'];

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
          decoration: const InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search, color: AppColors.grey),
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                          Text(g, style: Theme.of(context).textTheme.bodyLarge),
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
            // Results
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.68,
              ),
              itemCount: 4,
              itemBuilder: (context, i) => Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
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
