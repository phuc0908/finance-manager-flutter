import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/wallet_entity.dart';
import '../providers/wallet_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AddWalletPage extends ConsumerStatefulWidget {
  const AddWalletPage({super.key});

  @override
  ConsumerState<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends ConsumerState<AddWalletPage> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  WalletType _selectedType = WalletType.cash;
  String? _selectedIcon; // Placeholder for now, can implement icon picker later

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm ví mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên ví',
                  hintText: 'VD: Ví tiền mặt, VCB, Momo',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên ví';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FormField<WalletType>(
                initialValue: _selectedType,
                builder: (state) {
                  return InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Loại ví',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<WalletType>(
                        value: _selectedType,
                        isDense: true,
                        onChanged: (WalletType? newValue) {
                          setState(() {
                            _selectedType = newValue!;
                            state.didChange(newValue);
                          });
                        },
                        items: WalletType.values.map((WalletType type) {
                          return DropdownMenuItem<WalletType>(
                            value: type,
                            child: Text(_getWalletTypeName(type)),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: 'Số dư ban đầu',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'VND',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số dư';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Số tiền không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveWallet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Lưu ví'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  void _saveWallet() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    if (_formKey.currentState!.validate()) {
      final repository = ref.read(walletRepositoryProvider);
      final wallet = WalletEntity(
        userId: user.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        balance: double.parse(_balanceController.text),
        createdAt: DateTime.now(),
        icon: _selectedIcon,
      );

      final result = await repository.addWallet(wallet);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${failure.message}')));
        },
        (_) {
          ref.invalidate(walletListProvider); // Refresh list
          ref.invalidate(totalBalanceProvider); // Refresh dashboard balance
          Navigator.pop(context);
        },
      );
    }
  }
}
