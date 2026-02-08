import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/isar_service.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final FirestoreService? _firestoreService;

  WalletRepositoryImpl([this._firestoreService]);

  @override
  Future<Either<Failure, List<WalletEntity>>> getWallets({
    required String userId,
  }) async {
    try {
      final isar = await IsarService.getInstance();
      final wallets = await isar.walletEntitys
          .filter()
          .userIdEqualTo(userId)
          .findAll();
      return Right(wallets);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addWallet(WalletEntity wallet) async {
    try {
      final isar = await IsarService.getInstance();
      await isar.writeTxn(() async {
        await isar.walletEntitys.put(wallet);
      });

      // Background sync to Firestore
      _syncWithCloud(wallet);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateWallet(WalletEntity wallet) async {
    try {
      final isar = await IsarService.getInstance();
      await isar.writeTxn(() async {
        await isar.walletEntitys.put(wallet);
      });

      // Background sync to Firestore
      _syncWithCloud(wallet);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<void> _syncWithCloud(WalletEntity wallet) async {
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
  Future<Either<Failure, void>> saveWallets(List<WalletEntity> wallets) async {
    try {
      final isar = await IsarService.getInstance();
      await isar.writeTxn(() async {
        for (var wallet in wallets) {
          // Check if it already exists by firestoreId
          final existing = await isar.walletEntitys
              .filter()
              .firestoreIdEqualTo(wallet.firestoreId)
              .findFirst();

          if (existing != null) {
            wallet.id = existing.id; // Keep local id for update
          }
          await isar.walletEntitys.put(wallet);
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalBalance({
    required String userId,
  }) async {
    try {
      final isar = await IsarService.getInstance();
      final wallets = await isar.walletEntitys
          .filter()
          .userIdEqualTo(userId)
          .findAll();
      final total = wallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
      return Right(total);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllWallets({
    required String userId,
  }) async {
    try {
      final isar = await IsarService.getInstance();
      await isar.writeTxn(() async {
        await isar.walletEntitys.filter().userIdEqualTo(userId).deleteAll();
      });
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
