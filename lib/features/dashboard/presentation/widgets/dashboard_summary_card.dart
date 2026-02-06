import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';

class DashboardSummaryCard extends ConsumerWidget {
  const DashboardSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(totalBalanceProvider);
    final now = DateTime.now();
    final incomeAsync = ref.watch(incomeProvider(now));
    final expenseAsync = ref.watch(expenseProvider(now));

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng số dư',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            balanceAsync.when(
              data: (value) => currencyFormat.format(value),
              error: (_, __) => '0 ₫',
              loading: () => '...',
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.arrow_downward,
                  label: 'Thu nhập',
                  amount: incomeAsync.when(
                    data: (value) => currencyFormat.format(value),
                    error: (_, __) => '0 ₫',
                    loading: () => '...',
                  ),
                  color: Colors.white,
                  iconColor: Colors.greenAccent,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.arrow_upward,
                  label: 'Chi tiêu',
                  amount: expenseAsync.when(
                    data: (value) => currencyFormat.format(value),
                    error: (_, __) => '0 ₫',
                    loading: () => '...',
                  ),
                  color: Colors.white,
                  iconColor: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
