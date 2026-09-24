import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/cart_item_model.dart';
import '../../models/coupon_model.dart';
import '../../models/order_draft.dart';
import '../../theme/app_theme.dart';
import '../../widgets/step_indicator.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, required this.items});

  final List<CartItem> items;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  CouponModel? _coupon;

  num get _subtotal => widget.items.fold<num>(0, (sum, i) => sum + i.subtotal);

  num get _discount {
    if (_coupon == null) return 0;
    if (_subtotal < _coupon!.minTransaction) return 0;
    return _subtotal * _coupon!.percent / 100;
  }

  num get _finalPrice => _subtotal - _discount;

  Future<void> _openDiscount() async {
    final result = await context.push<CouponModel>('/discount');
    if (result != null) {
      setState(() => _coupon = result);
    }
  }

  void _continue() {
    final draft = OrderDraft(items: widget.items, coupon: _coupon);
    context.push('/shipping', extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SafeArea(child: const StepIndicator(current: 0)),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: widget.items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, i) {
                final item = widget.items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
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
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '\$ ${item.product.price}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.quantity}\nitem',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _openDiscount,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryLight),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _coupon == null
                              ? 'Enter coupon code'
                              : '${_coupon!.percent}% OFF applied',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _priceRow(
                  context,
                  'Total Price',
                  '\$ ${_subtotal.toStringAsFixed(2)}',
                ),
                _priceRow(
                  context,
                  'Discount fee',
                  '\$ ${_discount.toStringAsFixed(2)}',
                ),
                _priceRow(
                  context,
                  'Final Price',
                  '\$ ${_finalPrice.toStringAsFixed(2)}',
                  bold: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.items.isEmpty ? null : _continue,
                  child: const Text('Order'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
    BuildContext context,
    String label,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
