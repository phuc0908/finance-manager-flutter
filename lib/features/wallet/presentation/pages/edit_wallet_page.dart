import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/wallet_entity.dart';
import '../providers/wallet_provider.dart';

class EditWalletPage extends ConsumerStatefulWidget {
  final WalletEntity wallet;
  const EditWalletPage({super.key, required this.wallet});

  @override
  ConsumerState<EditWalletPage> createState() => _EditWalletPageState();
}

class _EditWalletPageState extends ConsumerState<EditWalletPage> {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late WalletType _selectedType;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet.name);
    // Remove formatting characters if any, simplistically assuming clean double for now or simple string
    _balanceController = TextEditingController(
      text: widget.wallet.balance.toStringAsFixed(0),
    );
    _selectedType = widget.wallet.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa ví')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bạn có thể điều chỉnh số dư thực tế tại đây nếu xảy ra sai lệch do lỗi trước đó.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                  labelText: 'Số dư hiện tại',
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
                  child: const Text('Cập nhật ví'),
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
    if (_formKey.currentState!.validate()) {
      final repository = ref.read(walletRepositoryProvider);

      // Update fields
      widget.wallet.name = _nameController.text.trim();
      widget.wallet.type = _selectedType;
      widget.wallet.balance = double.parse(_balanceController.text);
      widget.wallet.updatedAt = DateTime.now();

      final result = await repository.updateWallet(widget.wallet);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${failure.message}')));
        },
        (_) {
          ref.invalidate(walletListProvider); // Refresh list
          ref.invalidate(totalBalanceProvider); // Refresh dashboard balance
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật thông tin ví')),
            );
            Navigator.pop(context);
          }
        },
      );
    }
  }
}
