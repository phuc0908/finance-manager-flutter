import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getRecentTransactions({
    required String userId,
    int limit = 5,
  });
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions({
    required String userId,
  });
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, double>> getIncome({
    required String userId,
    required DateTime start,
    required DateTime end,
  });
  Future<Either<Failure, double>> getExpense({
    required String userId,
    required DateTime start,
    required DateTime end,
  });
  Future<Either<Failure, void>> deleteAllTransactions({required String userId});
}
