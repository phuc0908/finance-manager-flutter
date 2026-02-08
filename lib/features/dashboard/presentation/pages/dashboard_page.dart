import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../../transaction/presentation/pages/transaction_list_page.dart';
import '../../../transaction/presentation/pages/add_transaction_page.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/recent_transactions_list.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            backgroundImage: user?.photoUrl != null
                ? NetworkImage(user!.photoUrl!)
                : null,
            child: user?.photoUrl == null
                ? const Icon(
                    Icons.person,
                    size: 20,
                    color: AppTheme.primaryColor,
                  )
                : null,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletListProvider);
          ref.invalidate(recentTransactionsProvider);
          ref.invalidate(totalBalanceProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardSummaryCard(),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Giao dịch gần đây',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const TransactionListPage(), // Assuming AllTransactionsPage is TransactionListPage
                        ),
                      );
                    },
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const RecentTransactionsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
