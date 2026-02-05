import 'package:flutter/material.dart';

// Transaction Categories with Vietnamese names
class CategoryConstants {
  // Expense Categories
  static const Map<String, CategoryInfo> expenseCategories = {
    'food': CategoryInfo(
      name: 'Ăn uống',
      icon: Icons.restaurant,
      color: Color(0xFFFF6B6B),
    ),
    'transport': CategoryInfo(
      name: 'Đi lại',
      icon: Icons.directions_car,
      color: Color(0xFF4ECDC4),
    ),
    'shopping': CategoryInfo(
      name: 'Mua sắm',
      icon: Icons.shopping_bag,
      color: Color(0xFFFFD93D),
    ),
    'entertainment': CategoryInfo(
      name: 'Giải trí',
      icon: Icons.movie,
      color: Color(0xFF6BCF7F),
    ),
    'health': CategoryInfo(
      name: 'Sức khỏe',
      icon: Icons.local_hospital,
      color: Color(0xFFFF8B94),
    ),
    'education': CategoryInfo(
      name: 'Giáo dục',
      icon: Icons.school,
      color: Color(0xFF95E1D3),
    ),
    'bills': CategoryInfo(
      name: 'Hóa đơn',
      icon: Icons.receipt_long,
      color: Color(0xFFFFA07A),
    ),
    'other': CategoryInfo(
      name: 'Khác',
      icon: Icons.more_horiz,
      color: Color(0xFF9C88FF),
    ),
  };

  // Income Categories
  static const Map<String, CategoryInfo> incomeCategories = {
    'salary': CategoryInfo(
      name: 'Lương',
      icon: Icons.attach_money,
      color: Color(0xFF51CF66),
    ),
    'investment': CategoryInfo(
      name: 'Đầu tư',
      icon: Icons.trending_up,
      color: Color(0xFF339AF0),
    ),
    'freelance': CategoryInfo(
      name: 'Freelance',
      icon: Icons.work,
      color: Color(0xFFFF6B6B),
    ),
    'gift': CategoryInfo(
      name: 'Quà tặng',
      icon: Icons.card_giftcard,
      color: Color(0xFFFFD93D),
    ),
    'other': CategoryInfo(
      name: 'Khác',
      icon: Icons.more_horiz,
      color: Color(0xFF9C88FF),
    ),
  };

  static CategoryInfo? getCategory(String key, bool isIncome) {
    return isIncome ? incomeCategories[key] : expenseCategories[key];
  }
}

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryInfo({
    required this.name,
    required this.icon,
    required this.color,
  });
}
