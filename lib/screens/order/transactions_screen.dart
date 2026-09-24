import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';
import '../../theme/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _tab = 0;

  final _statuses = ['pending', 'processing', 'completed'];
  final _tabLabels = ['Need to Pay', 'On The Way', 'History'];
  final _tabIcons = [
    Icons.credit_card_outlined,
    Icons.location_on_outlined,
    Icons.inventory_2_outlined,
  ];

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      alignment: Alignment.centerLeft,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const Text(
                      'Transactions',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: List.generate(
                3,
                (i) => _tabItem(i, _tabIcons[i], _tabLabels[i]),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.white,
              child: StreamBuilder<List<OrderModel>>(
                stream: OrderRepository.instance.watchByUserAndStatus(
                  _uid,
                  _statuses[_tab],
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  final orders = snapshot.data ?? [];
                  if (orders.isEmpty) {
                    return const Center(child: Text('Belum ada transaksi'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: orders.length,
                    itemBuilder: (context, i) => _orderCard(context, orders[i]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(BuildContext context, OrderModel order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.checkroom_outlined,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '\$ ${item.price}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${item.quantity} item',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Text(
              'Total: \$ ${order.total.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(int index, IconData icon, String label) {
    final active = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: active ? AppColors.white : AppColors.grey,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: active ? AppColors.white : AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
