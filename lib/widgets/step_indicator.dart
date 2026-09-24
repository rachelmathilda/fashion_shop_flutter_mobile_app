import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final labels = ['Order', 'Shipping', 'Payment'];
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      child: Row(
        children: List.generate(3, (i) {
          final active = i <= current;
          return Expanded(
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.greyLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: active ? AppColors.primary : AppColors.grey,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
