import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/coupon_model.dart';
import '../../repositories/coupon_repository.dart';
import '../../theme/app_theme.dart';

class DiscountScreen extends StatelessWidget {
  const DiscountScreen({super.key});

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
          'Discount',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<CouponModel>>(
        stream: CouponRepository.instance.watchActive(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final coupons = snapshot.data ?? [];
          if (coupons.isEmpty) {
            return const Center(child: Text('Belum ada kupon tersedia'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: coupons.length,
            itemBuilder: (context, i) => _couponCard(context, coupons[i]),
          );
        },
      ),
    );
  }

  Widget _couponCard(BuildContext context, CouponModel coupon) {
    final dateLabel = DateFormat('d MMMM yyyy').format(coupon.validUntil);
    final scopeLabel = coupon.category == 'all'
        ? 'for all products'
        : 'for all of the ${coupon.category.toLowerCase()} products';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              children: [
                Text(
                  '${coupon.percent.toStringAsFixed(0)}% OFF',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\u2022 $scopeLabel\n\u2022 for minimum \$${coupon.minTransaction.toStringAsFixed(0)} transaction\n\u2022 until $dateLabel',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          GestureDetector(
            onTap: () => context.pop(coupon),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Apply',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
