import 'package:isar/isar.dart';

part 'transaction_entity.g.dart';

@collection
class TransactionEntity {
  Id id = Isar.autoIncrement;

  late String userId;

  late double amount;

  @enumerated
  late TransactionType type;

  late String category; // food, transport, shopping, salary, investment, etc.

  late String walletId;

  String? note;

  String? receiptImageUrl; // URL to OCR scanned receipt

  @Index()
  late DateTime createdAt;

  DateTime? updatedAt;

  // For cloud sync
  String? firestoreId;
  bool isSynced = false;

  TransactionEntity({
    this.id = Isar.autoIncrement,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.walletId,
    this.note,
    this.receiptImageUrl,
    required this.createdAt,
    this.updatedAt,
    this.firestoreId,
    this.isSynced = false,
  });

  // Convert to map for Firestore
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'amount': amount,
    'type': type.name,
    'category': category,
    'walletId': walletId,
    'note': note,
    'receiptImageUrl': receiptImageUrl,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  // Create from Firestore
  factory TransactionEntity.fromJson(
    Map<String, dynamic> json,
    String firestoreId,
  ) {
    return TransactionEntity(
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      category: json['category'] as String,
      walletId: json['walletId'] as String,
      note: json['note'] as String?,
      receiptImageUrl: json['receiptImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      firestoreId: firestoreId,
      isSynced: true,
    );
  }
}

enum TransactionType { income, expense }
