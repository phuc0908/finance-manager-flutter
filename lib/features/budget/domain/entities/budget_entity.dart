import 'package:isar/isar.dart';

part 'budget_entity.g.dart';

@collection
class BudgetEntity {
  Id id = Isar.autoIncrement;

  late String userId;

  late String category; // Category to budget for

  late double limitAmount; // Giới hạn chi tiêu

  late int month; // 1-12

  late int year; // 2024, 2025, etc.

  @Index()
  late DateTime createdAt;

  DateTime? updatedAt;

  // For cloud sync
  String? firestoreId;
  bool isSynced = false;

  BudgetEntity({
    this.id = Isar.autoIncrement,
    required this.userId,
    required this.category,
    required this.limitAmount,
    required this.month,
    required this.year,
    required this.createdAt,
    this.updatedAt,
    this.firestoreId,
    this.isSynced = false,
  });

  // Composite index for month/year queries
  @Index(composite: [CompositeIndex('month'), CompositeIndex('year')])
  String get monthYearKey => '$year-${month.toString().padLeft(2, '0')}';

  // Convert to map for Firestore
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'category': category,
    'limitAmount': limitAmount,
    'month': month,
    'year': year,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  // Create from Firestore
  factory BudgetEntity.fromJson(Map<String, dynamic> json, String firestoreId) {
    return BudgetEntity(
      userId: json['userId'] as String,
      category: json['category'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      firestoreId: firestoreId,
      isSynced: true,
    );
  }
}
