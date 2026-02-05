import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Format tiền Việt Nam Đồng
  static String formatVND(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Format số tiền chung
  static String format(double amount, {String currency = 'VND'}) {
    if (currency == 'VND') {
      return formatVND(amount);
    }
    // Có thể thêm các currency khác sau
    return amount.toStringAsFixed(2);
  }

  // Format compact (1.5K, 2.3M, etc.)
  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class DateFormatter {
  // Format ngày theo định dạng Việt Nam
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format giờ
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Format ngày giờ đầy đủ
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Format relative (Hôm nay, Hôm qua, etc.)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hôm nay';
    } else if (dateOnly == yesterday) {
      return 'Hôm qua';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE', 'vi_VN').format(date);
    }
    return formatDate(date);
  }

  // Format tháng/năm
  static String formatMonthYear(DateTime date) {
    return DateFormat('MM/yyyy').format(date);
  }

  // Parse từ string
  static DateTime? parseDate(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}
