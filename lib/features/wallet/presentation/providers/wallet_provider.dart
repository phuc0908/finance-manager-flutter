import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

import '../../../../core/services/firestore_service.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(ref.watch(firestoreServiceProvider));
});

final walletListProvider = FutureProvider<List<WalletEntity>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];

  final repository = ref.watch(walletRepositoryProvider);
  final result = await repository.getWallets(userId: user.id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (wallets) => wallets,
  );
});

final totalBalanceProvider = FutureProvider<double>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return 0.0;

  final repository = ref.watch(walletRepositoryProvider);
  final result = await repository.getTotalBalance(userId: user.id);
  return result.fold((failure) => 0.0, (balance) => balance);
});
