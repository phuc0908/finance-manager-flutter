import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/transaction/domain/repositories/transaction_repository.dart';
import '../../features/wallet/presentation/providers/wallet_provider.dart';
import '../../features/transaction/presentation/providers/transaction_provider.dart';
import 'firestore_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(firestoreServiceProvider),
    ref.watch(walletRepositoryProvider),
    ref.watch(transactionRepositoryProvider),
  );
});

class SyncService {
  final FirestoreService _firestoreService;
  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;

  SyncService(
    this._firestoreService,
    this._walletRepository,
    this._transactionRepository,
  );

  Future<void> syncFromCloud(String userId) async {
    // 1. Sync Wallets
    final wallets = await _firestoreService.getWallets(userId);
    if (wallets.isNotEmpty) {
      await _walletRepository.saveWallets(wallets);
    }

    // 2. Sync Transactions
    final transactions = await _firestoreService.getTransactions(userId);
    if (transactions.isNotEmpty) {
      await _transactionRepository.saveTransactions(transactions);
    }
  }

  Future<void> forceSync(String userId) async {
    // 1. Wipe local transactions first
    await _transactionRepository.deleteAllTransactions(userId: userId);

    // 2. Wipe local wallets
    await _walletRepository.deleteAllWallets(userId: userId);

    // 3. Pull fresh data from cloud
    await syncFromCloud(userId);
  }
}
