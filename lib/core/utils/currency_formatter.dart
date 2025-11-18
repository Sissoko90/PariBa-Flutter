import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Currency Formatting Utilities
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat('#,##0', 'fr_FR');

  /// Format amount with currency symbol
  static String format(double amount, {bool showSymbol = true}) {
    final formatted = _formatter.format(amount);
    return showSymbol ? '$formatted ${AppConstants.currencySymbol}' : formatted;
  }

  /// Format amount from int
  static String formatInt(int amount, {bool showSymbol = true}) {
    return format(amount.toDouble(), showSymbol: showSymbol);
  }

  /// Format amount from string
  static String formatString(String amount, {bool showSymbol = true}) {
    final value = double.tryParse(amount) ?? 0.0;
    return format(value, showSymbol: showSymbol);
  }

  /// Parse formatted string to double
  static double? parse(String formattedAmount) {
    try {
      // Remove currency symbol and spaces
      String cleaned = formattedAmount
          .replaceAll(AppConstants.currencySymbol, '')
          .replaceAll(' ', '')
          .replaceAll(',', '');
      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Format amount with sign (+ or -)
  static String formatWithSign(double amount, {bool showSymbol = true}) {
    final sign = amount >= 0 ? '+' : '';
    final formatted = format(amount.abs(), showSymbol: showSymbol);
    return '$sign$formatted';
  }

  /// Format compact (1K, 1M, etc.)
  static String formatCompact(double amount, {bool showSymbol = true}) {
    String formatted;
    
    if (amount >= 1000000000) {
      formatted = '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      formatted = '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      formatted = '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      formatted = amount.toStringAsFixed(0);
    }
    
    return showSymbol ? '$formatted ${AppConstants.currencySymbol}' : formatted;
  }

  /// Format percentage
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Calculate percentage
  static double calculatePercentage(double part, double total) {
    if (total == 0) return 0;
    return (part / total) * 100;
  }
}
