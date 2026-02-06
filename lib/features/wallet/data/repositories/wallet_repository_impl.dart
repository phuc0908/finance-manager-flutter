import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/isar_service.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
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
}
