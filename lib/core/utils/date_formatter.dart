import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Date Formatting Utilities
class DateFormatter {
  DateFormatter._();

  /// Format date to dd/MM/yyyy
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  /// Format date to dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime date) {
    return DateFormat(AppConstants.dateTimeFormat).format(date);
  }

  /// Format time to HH:mm
  static String formatTime(DateTime date) {
    return DateFormat(AppConstants.timeFormat).format(date);
  }

  /// Parse date string to DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat(AppConstants.dateFormat).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse ISO 8601 date string
  static DateTime? parseIso8601(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get relative time (il y a X minutes/heures/jours)
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks sem';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Get day name (Lundi, Mardi, etc.)
  static String getDayName(DateTime date) {
    return DateFormat('EEEE', 'fr_FR').format(date);
  }

  /// Get month name (Janvier, Février, etc.)
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM', 'fr_FR').format(date);
  }

  /// Format for display (Aujourd'hui, Hier, or date)
  static String formatForDisplay(DateTime date) {
    if (isToday(date)) {
      return 'Aujourd\'hui à ${formatTime(date)}';
    } else if (isYesterday(date)) {
      return 'Hier à ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }

  /// Alias for getRelativeTime
  static String formatRelative(DateTime date) => getRelativeTime(date);
}
