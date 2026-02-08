import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/sync_service.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _nameController = TextEditingController();
  final _photoUrlController = TextEditingController();
  bool _isEditingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Cài đặt')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Section
            _buildProfileCard(user),
            const SizedBox(height: 32),

            // Settings List
            _buildSettingsList(context, ref, user),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      onTap: () => _showEditAvatarDialog(user?.photoUrl),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nickname
            if (!_isEditingName)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user?.displayName ?? 'Chưa đặt tên',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      setState(() {
                        _nameController.text = user?.displayName ?? '';
                        _isEditingName = true;
                      });
                    },
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập nickname mới',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: _updateName,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => setState(() => _isEditingName = false),
                  ),
                ],
              ),

            // Email (Non-editable)
            Text(user?.email ?? '', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref, dynamic user) {
    return Column(
      children: [
        _buildSettingsItem(
          icon: Icons.sync,
          title: 'Đồng bộ dữ liệu',
          subtitle: 'Xóa dữ liệu máy và tải lại từ Cloud',
          onTap: () => _handleForceSync(context, ref, user),
        ),
        _buildSettingsItem(
          icon: Icons.language,
          title: 'Ngôn ngữ',
          subtitle: 'Tiếng Việt', // TODO: Logic for language
          onTap: () => _showLanguageDialog(),
        ),
        const Divider(height: 32),
        _buildSettingsItem(
          icon: Icons.logout,
          title: 'Đăng xuất',
          titleColor: Colors.red,
          onTap: () => _handleLogout(context, ref),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (titleColor ?? AppTheme.primaryColor).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: titleColor ?? AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: titleColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Future<void> _updateName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    await ref
        .read(authControllerProvider.notifier)
        .updateProfile(name: newName);
    setState(() => _isEditingName = false);
  }

  void _showEditAvatarDialog(String? currentUrl) {
    _photoUrlController.text = currentUrl ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi ảnh đại diện'),
        content: TextField(
          controller: _photoUrlController,
          decoration: const InputDecoration(
            labelText: 'URL Ảnh',
            hintText: 'Nhập đường dẫn ảnh trực tuyến',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final newUrl = _photoUrlController.text.trim();
              await ref
                  .read(authControllerProvider.notifier)
                  .updateProfile(photoUrl: newUrl);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _handleForceSync(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
  ) async {
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đồng bộ'),
        content: const Text(
          'Hành động này sẽ xóa dữ liệu hiện tại trên máy và tải lại toàn bộ dữ liệu từ Cloud. Bạn có chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đồng bộ ngay'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đang đồng bộ dữ liệu...')));
      await ref.read(syncServiceProvider).forceSync(user.id);

      ref.invalidate(walletListProvider);
      ref.invalidate(recentTransactionsProvider);
      ref.invalidate(allTransactionsProvider);
      ref.invalidate(totalBalanceProvider);
      ref.invalidate(incomeProvider);
      ref.invalidate(expenseProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã đồng bộ thành công!')));
      }
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Chọn ngôn ngữ'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Row(
              children: [
                const Text('🇻🇳 Tiếng Việt'),
                const Spacer(),
                const Icon(Icons.check, color: AppTheme.primaryColor),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: const Text('🇺🇸 Tiếng Anh'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }
}
