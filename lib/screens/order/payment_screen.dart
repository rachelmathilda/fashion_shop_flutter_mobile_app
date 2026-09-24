import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/order_draft.dart';
import '../../models/order_model.dart';
import '../../repositories/cart_repository.dart';
import '../../repositories/order_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/step_indicator.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.draft});

  final OrderDraft draft;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'Credit Card';
  bool _isPaying = false;

  final _methods = [
    {'label': 'Credit Card', 'icon': Icons.credit_card},
    {'label': 'Google Pay', 'icon': Icons.g_mobiledata},
    {'label': 'Paypal', 'icon': Icons.paypal_outlined},
    {'label': 'Apple Pay', 'icon': Icons.apple},
  ];

  Future<void> _pay() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan login dulu')));
      return;
    }

    setState(() => _isPaying = true);

    try {
      final order = OrderModel(
        id: '',
        userId: uid,
        items: widget.draft.items
            .map(
              (i) => OrderItem(
                productId: i.product.id,
                productName: i.product.name,
                imageUrl: i.product.imageUrl,
                price: i.product.price,
                quantity: i.quantity,
                selectedSize: i.selectedSize,
              ),
            )
            .toList(),
        subtotal: widget.draft.subtotal,
        discountAmount: widget.draft.discountAmount,
        couponCode: widget.draft.coupon?.code,
        deliveryFee: widget.draft.deliveryFee,
        total: widget.draft.total,
        status: 'processing',
        paymentMethod: _method,
        addressText: widget.draft.addressText,
        addressLat: widget.draft.addressLat,
        addressLng: widget.draft.addressLng,
        createdAt: DateTime.now(),
      );

      final orderId = await OrderRepository.instance.createOrder(order);

      for (final item in widget.draft.items) {
        await CartRepository.instance.removeItem(uid, item.product.id);
      }

      if (!mounted) return;
      final createdOrder = await OrderRepository.instance.fetchById(orderId);
      context.push('/payment-success', extra: createdOrder ?? order);
    } catch (_) {
      if (!mounted) return;
      context.push('/payment-fail');
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SafeArea(child: const StepIndicator(current: 2)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$ ${widget.draft.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.6,
                        ),
                    itemCount: _methods.length,
                    itemBuilder: (context, i) {
                      final m = _methods[i];
                      final selected = _method == m['label'];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _method = m['label'] as String),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: selected
                                ? Border.all(color: AppColors.primary, width: 2)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                m['icon'] as IconData,
                                size: 30,
                                color: AppColors.black,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                m['label'] as String,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ini simulasi pembayaran, tidak ada transaksi kartu beneran.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: ElevatedButton(
              onPressed: _isPaying ? null : _pay,
              child: _isPaying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Pay'),
            ),
          ),
        ],
      ),
    );
  }
}
