import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../../wallet/presentation/pages/add_wallet_page.dart';
import '../providers/transaction_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'food'; // Default
  WalletEntity? _selectedWallet;

  final _formKey = GlobalKey<FormState>();

  final Map<String, IconData> _categories = {
    'food': Icons.fastfood,
    'transport': Icons.directions_bus,
    'shopping': Icons.shopping_bag,
    'salary': Icons.work,
    'investment': Icons.trending_up,
    'other': Icons.category,
  };

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm giao dịch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Selector (Income/Expense)
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      type: TransactionType.expense,
                      label: 'Chi tiêu',
                      color: AppTheme.errorColor,
                      isSelected: _type == TransactionType.expense,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTypeButton(
                      type: TransactionType.income,
                      label: 'Thu nhập',
                      color: AppTheme.successColor,
                      isSelected: _type == TransactionType.income,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'VND',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Số tiền không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Wallet Selector
              walletsAsync.when(
                data: (wallets) {
                  if (wallets.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bạn chưa có ví nào. Vui lòng tạo ví trước.',
                          style: TextStyle(color: Colors.red),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddWalletPage(),
                              ),
                            ).then((_) {
                              ref.invalidate(walletListProvider);
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Tạo ví ngay'),
                        ),
                      ],
                    );
                  }

                  // Set default wallet if not set
                  if (_selectedWallet == null && wallets.isNotEmpty) {
                    Future.microtask(() {
                      if (mounted) {
                        setState(() {
                          _selectedWallet = wallets.firstWhere(
                            (w) => w.isDefault,
                            orElse: () => wallets.first,
                          );
                        });
                      }
                    });
                  }

                  return DropdownButtonFormField<WalletEntity>(
                    value: _selectedWallet,
                    decoration: const InputDecoration(
                      labelText: 'Ví',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    items: wallets.map((wallet) {
                      return DropdownMenuItem(
                        value: wallet,
                        child: Text(
                          '${wallet.name} (${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(wallet.balance)})',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWallet = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Vui lòng chọn ví' : null,
                  );
                },
                error: (e, _) => Text('Lỗi tải ví: $e'),
                loading: () => const LinearProgressIndicator(),
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày giao dịch',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Category Selector (Simplified)
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.entries.map((e) {
                  return DropdownMenuItem(
                    value: e.key,
                    child: Row(
                      children: [
                        Icon(e.value, size: 20),
                        const SizedBox(width: 8),
                        Text(e.key), // TODO: Translate keys
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Lưu giao dịch'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required String label,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _type = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _saveTransaction() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    if (_formKey.currentState!.validate() && _selectedWallet != null) {
      final repository = ref.read(transactionRepositoryProvider);

      final transaction = TransactionEntity(
        userId: user.id,
        amount: double.parse(_amountController.text),
        type: _type,
        category: _selectedCategory,
        walletId: _selectedWallet!.id
            .toString(), // Assuming string ID for now, might need fix if int
        note: _noteController.text.trim(),
        createdAt: _selectedDate,
      );

      final result = await repository.addTransaction(transaction);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${failure.message}')));
        },
        (_) {
          // Update Wallet Balance logic should be in repository or use-case,
          // but for now we invalidate to force refresh.
          // Note: Ideally, TransactionRepository.addTransaction should update WalletEntity balance.
          ref.invalidate(recentTransactionsProvider);
          ref.invalidate(allTransactionsProvider); // Refresh list
          ref.invalidate(totalBalanceProvider);
          ref.invalidate(incomeProvider);
          ref.invalidate(expenseProvider);
          Navigator.pop(context);
        },
      );
    }
  }
}
