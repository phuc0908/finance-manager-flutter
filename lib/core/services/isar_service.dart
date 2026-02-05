import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/transaction/domain/entities/transaction_entity.dart';
import '../../features/wallet/domain/entities/wallet_entity.dart';
import '../../features/budget/domain/entities/budget_entity.dart';

class IsarService {
  static Isar? _instance;

  static Future<Isar> getInstance() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open([
      TransactionEntitySchema,
      WalletEntitySchema,
      BudgetEntitySchema,
    ], directory: dir.path);

    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
