import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, List<WalletEntity>>> getWallets({
    required String userId,
  });
  Future<Either<Failure, void>> addWallet(WalletEntity wallet);
  Future<Either<Failure, void>> updateWallet(WalletEntity wallet);
  Future<Either<Failure, double>> getTotalBalance({required String userId});
}
