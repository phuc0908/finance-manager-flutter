import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'add_transaction_page.dart';

class TransactionListPage extends ConsumerWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Re-using recentTransactionsProvider for now, but should ideally implement a "allTransactions" or pagination
    // For this MVP phase, let's fetch more items or a different provider.
    // Let's assume re-using recent with higher limit for now.
    // Use allTransactionsProvider instead of recent
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              // Confirm dialog
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xóa tất cả?'),
                  content: const Text(
                    'Bạn có chắc chắn muốn xóa toàn bộ lịch sử giao dịch không? Hành động này không thể hoàn tác.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final user = ref.read(authStateProvider).value;
                if (user != null) {
                  await ref
                      .read(transactionRepositoryProvider)
                      .deleteAllTransactions(userId: user.id);
                  ref.invalidate(recentTransactionsProvider);
                  ref.invalidate(allTransactionsProvider);
                  ref.invalidate(totalBalanceProvider);
                  ref.invalidate(incomeProvider);
                  ref.invalidate(expenseProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa toàn bộ giao dịch')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('Chưa có giao dịch nào'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isIncome = transaction.type == TransactionType.income;
              final color = isIncome
                  ? AppTheme.successColor
                  : AppTheme.errorColor;
              IconData categoryIcon = Icons.category;
              if (transaction.category == 'food') categoryIcon = Icons.fastfood;
              if (transaction.category == 'transport')
                categoryIcon = Icons.directions_bus;
              if (transaction.category == 'shopping')
                categoryIcon = Icons.shopping_bag;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListTile(
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).format(transaction.createdAt),
                  ),
                  trailing: Text(
                    '${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
