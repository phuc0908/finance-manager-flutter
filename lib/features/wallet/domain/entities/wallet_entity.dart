import 'package:isar/isar.dart';

part 'wallet_entity.g.dart';

@collection
class WalletEntity {
  Id id = Isar.autoIncrement;

  late String userId;

  late String name; // Tiền mặt, Ngân hàng VCB, Ví Momo, etc.

  @enumerated
  late WalletType type;

  late double balance;

  String currency = 'VND'; // Default to VND

  String? icon; // Icon name for the wallet

  @Index()
  late DateTime createdAt;

  DateTime? updatedAt;

  // For cloud sync
  String? firestoreId;
  bool isSynced = false;

  bool isDefault = false; // Ví mặc định

  WalletEntity({
    this.id = Isar.autoIncrement,
    required this.userId,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.currency = 'VND',
    this.icon,
    required this.createdAt,
    this.updatedAt,
    this.firestoreId,
    this.isSynced = false,
    this.isDefault = false,
  });

  // Convert to map for Firestore
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'type': type.name,
    'balance': balance,
    'currency': currency,
    'icon': icon,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isDefault': isDefault,
  };

  // Create from Firestore
  factory WalletEntity.fromJson(Map<String, dynamic> json, String firestoreId) {
    return WalletEntity(
      userId: json['userId'] as String,
      name: json['name'] as String,
      type: WalletType.values.firstWhere((e) => e.name == json['type']),
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'VND',
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      firestoreId: firestoreId,
      isSynced: true,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

enum WalletType {
  cash, // Tiền mặt
  bank, // Ngân hàng
  ewallet, // Ví điện tử
}
