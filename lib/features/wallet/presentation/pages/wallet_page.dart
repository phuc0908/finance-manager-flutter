import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/wallet_entity.dart';
import '../providers/wallet_provider.dart';
import 'add_wallet_page.dart';
import 'edit_wallet_page.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletListProvider);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý ví'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddWalletPage()),
              );
            },
          ),
        ],
      ),
      body: walletsAsync.when(
        data: (wallets) {
          if (wallets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('Bạn chưa có ví nào'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddWalletPage(),
                        ),
                      );
                    },
                    child: const Text('Thêm ví ngay'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              return Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditWalletPage(wallet: wallet),
                      ),
                    );
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getWalletIcon(wallet.type),
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(
                    wallet.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_getWalletTypeName(wallet.type)),
                  trailing: Text(
                    currencyFormat.format(wallet.balance),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryColor,
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
    );
  }

  IconData _getWalletIcon(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return Icons.money;
      case WalletType.bank:
        return Icons.account_balance;
      case WalletType.ewallet:
        return Icons.account_balance_wallet;
    }
  }

  String _getWalletTypeName(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return 'Tiền mặt';
      case WalletType.bank:
        return 'Ngân hàng';
      case WalletType.ewallet:
        return 'Ví điện tử';
    }
  }
}
