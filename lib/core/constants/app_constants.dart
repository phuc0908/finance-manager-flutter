// App Constants
class AppConstants {
  // App Info
  static const String appName = 'Finance Manager';
  static const String appVersion = '1.0.0';

  // Default Values
  static const String defaultCurrency = 'VND';
  static const int defaultBudgetWarningThreshold = 90; // 90%

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Storage Keys
  static const String isFirstLaunch = 'is_first_launch';
  static const String userIdKey = 'user_id';
  static const String selectedWalletKey = 'selected_wallet';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String walletsCollection = 'wallets';
  static const String budgetsCollection = 'budgets';
}
