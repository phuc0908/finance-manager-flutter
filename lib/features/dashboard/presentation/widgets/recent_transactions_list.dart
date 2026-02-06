import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';

class RecentTransactionsList extends ConsumerWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Chưa có giao dịch nào gần đây'),
            ),
          );
        }
        return Column(
          children: transactions
              .map((tx) => _buildTransactionItem(context, tx))
              .toList(),
        );
      },
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppTheme.successColor : AppTheme.errorColor;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    // Choose icon based on category (simple map for now)
    IconData categoryIcon = Icons.category;
    if (transaction.category == 'food') categoryIcon = Icons.fastfood;
    if (transaction.category == 'transport')
      categoryIcon = Icons.directions_bus;
    if (transaction.category == 'shopping') categoryIcon = Icons.shopping_bag;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(categoryIcon, color: color),
        ),
        title: Text(
          transaction.note?.isNotEmpty == true
              ? transaction.note!
              : transaction.category,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(transaction.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
