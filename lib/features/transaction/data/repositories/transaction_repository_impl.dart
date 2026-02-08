import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/isar_service.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirestoreService? _firestoreService;

  TransactionRepositoryImpl([this._firestoreService]);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getRecentTransactions({
    required String userId,
    int limit = 5,
  }) async {
    try {
      final isar = await IsarService.getInstance();
      final transactions = await isar.transactionEntitys
          .filter()
          .userIdEqualTo(userId)
          .sortByCreatedAtDesc()
          .limit(limit)
          .findAll();
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions({
    required String userId,
  }) async {
    try {
      final isar = await IsarService.getInstance();
      final transactions = await isar.transactionEntitys
          .filter()
          .userIdEqualTo(userId)
          .sortByCreatedAtDesc()
          .findAll();
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final isar = await IsarService.getInstance();
      WalletEntity? updatedWallet;
      await isar.writeTxn(() async {
        await isar.transactionEntitys.put(transaction);

        // Update wallet balance - Use get() for direct ID access
        final intId = int.tryParse(transaction.walletId);
        if (intId != null) {
          final wallet = await isar.walletEntitys.get(intId);

          if (wallet != null) {
            final amount = transaction.amount;
            if (transaction.type == TransactionType.income) {
              wallet.balance += amount;
            } else {
              wallet.balance -= amount;
            }
            await isar.walletEntitys.put(wallet);
            updatedWallet = wallet;
          }
        }
      });

      // Background sync to Firestore (Outside writeTxn)
      if (updatedWallet != null) {
        _syncWalletWithCloud(updatedWallet!);
      }
      _syncWithCloud(transaction);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<void> _syncWithCloud(TransactionEntity transaction) async {
    if (_firestoreService == null) return;

    final firestoreId = await _firestoreService.syncTransaction(transaction);
    if (firestoreId != null) {
      final isar = await IsarService.getInstance();
      await isar.writeTxn(() async {
        transaction.firestoreId = firestoreId;
        transaction.isSynced = true;
        await isar.transactionEntitys.put(transaction);
      });
    }
  }

  Future<void> _syncWalletWithCloud(WalletEntity wallet) async {
    if (_firestoreService == null) return;

    final firestoreId = await _firestoreService.syncWallet(wallet);
    if (firestoreId != null) {
      final isar = await IsarService.getInstance();
      await isar.writeTxn(() async {
        wallet.firestoreId = firestoreId;
        wallet.isSynced = true;
        await isar.walletEntitys.put(wallet);
      });
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllTransactions({
    required String userId,
  }) async {
    try {
      final isar = await IsarService.getInstance();
      final Set<WalletEntity> affectedWallets = {};
      await isar.writeTxn(() async {
        // Fetch all transactions for THIS user first
        final transactions = await isar.transactionEntitys
            .filter()
            .userIdEqualTo(userId)
            .findAll();

        // Revert wallet balances
        for (final transaction in transactions) {
          final wallet = await isar.walletEntitys
              .filter()
              .idEqualTo(int.tryParse(transaction.walletId) ?? -1)
              .findFirst();

          if (wallet != null) {
            final amount = transaction.amount;
            // Reverse logic: Income -> Subtract, Expense -> Add
            if (transaction.type == TransactionType.income) {
              wallet.balance -= amount;
            } else {
              wallet.balance += amount;
            }
            await isar.walletEntitys.put(wallet);
            affectedWallets.add(wallet);
          }
        }

        // Clear all transactions for THIS user
        await isar.transactionEntitys
            .filter()
            .userIdEqualTo(userId)
            .deleteAll();
      });

      // Sync affected wallets to cloud (Outside writeTxn)
      for (var wallet in affectedWallets) {
        _syncWalletWithCloud(wallet);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getIncome({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final isar = await IsarService.getInstance();
      final transactions = await isar.transactionEntitys
          .filter()
          .userIdEqualTo(userId)
          .typeEqualTo(TransactionType.income)
          .createdAtBetween(start, end)
          .findAll();

      final total = transactions.fold(0.0, (sum, item) => sum + item.amount);
      return Right(total);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getExpense({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final isar = await IsarService.getInstance();
      final transactions = await isar.transactionEntitys
          .filter()
          .userIdEqualTo(userId)
          .typeEqualTo(TransactionType.expense)
          .createdAtBetween(start, end)
          .findAll();

      final total = transactions.fold(0.0, (sum, item) => sum + item.amount);
      return Right(total);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveTransactions(
    List<TransactionEntity> transactions,
  ) async {
    try {
      final isar = await IsarService.getInstance();
      await isar.writeTxn(() async {
        for (var transaction in transactions) {
          // Check if it already exists by firestoreId
          final existing = await isar.transactionEntitys
              .filter()
              .firestoreIdEqualTo(transaction.firestoreId)
              .findFirst();

          if (existing != null) {
            transaction.id = existing.id; // Keep local id for update
          }
          await isar.transactionEntitys.put(transaction);
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
