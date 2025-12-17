import 'package:intl/intl.dart';

/// Utility class for formatting data
class Formatters {
  // Currency formatter for Indonesian Rupiah
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Number formatter with thousand separator
  static String formatNumber(double number, {int decimalDigits = 0}) {
    final formatter = NumberFormat.decimalPattern('id_ID');
    if (decimalDigits > 0) {
      return number.toStringAsFixed(decimalDigits);
    }
    return formatter.format(number);
  }

  // Date formatter
  static String formatDate(DateTime date, {String pattern = 'dd MMM yyyy'}) {
    final formatter = DateFormat(pattern, 'id_ID');
    return formatter.format(date);
  }

  // DateTime formatter
  static String formatDateTime(DateTime dateTime,
      {String pattern = 'dd MMM yyyy HH:mm'}) {
    final formatter = DateFormat(pattern, 'id_ID');
    return formatter.format(dateTime);
  }

  // Relative time (e.g., "2 jam yang lalu")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  // Weight formatter
  static String formatWeight(double weight, String unit) {
    if (weight >= 1000 && unit == 'Kg') {
      return '${formatNumber(weight / 1000, decimalDigits: 2)} Ton';
    }
    return '${formatNumber(weight)} $unit';
  }

  // Percentage formatter
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }

  // Phone number formatter
  static String formatPhoneNumber(String phone) {
    // Format: 0812-3456-7890
    if (phone.length >= 10) {
      return '${phone.substring(0, 4)}-${phone.substring(4, 8)}-${phone.substring(8)}';
    }
    return phone;
  }
}
