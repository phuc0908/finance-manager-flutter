import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl();
});

final recentTransactionsProvider =
    FutureProvider.autoDispose<List<TransactionEntity>>((ref) async {
      final user = ref.watch(authStateProvider).value;
      if (user == null) return [];

      final repository = ref.watch(transactionRepositoryProvider);
      final result = await repository.getRecentTransactions(
        userId: user.id,
        limit: 5,
      );
      return result.fold((failure) => [], (transactions) => transactions);
    });

final allTransactionsProvider =
    FutureProvider.autoDispose<List<TransactionEntity>>((ref) async {
      final user = ref.watch(authStateProvider).value;
      if (user == null) return [];

      final repository = ref.watch(transactionRepositoryProvider);
      final result = await repository.getAllTransactions(userId: user.id);
      return result.fold((failure) => [], (transactions) => transactions);
    });

final incomeProvider = FutureProvider.family<double, DateTime>((
  ref,
  now,
) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return 0.0;

  final repository = ref.watch(transactionRepositoryProvider);
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0);
  final result = await repository.getIncome(
    userId: user.id,
    start: start,
    end: end,
  );
  return result.fold((l) => 0.0, (r) => r);
});

final expenseProvider = FutureProvider.family<double, DateTime>((
  ref,
  now,
) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return 0.0;

  final repository = ref.watch(transactionRepositoryProvider);
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0);
  final result = await repository.getExpense(
    userId: user.id,
    start: start,
    end: end,
  );
  return result.fold((l) => 0.0, (r) => r);
});
