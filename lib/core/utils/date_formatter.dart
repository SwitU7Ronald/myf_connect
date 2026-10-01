import 'package:intl/intl.dart';
import 'package:myf_connect/core/constants/app_constants.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime? date, {String? format}) {
    if (date == null) return '';
    return DateFormat(format ?? AppConstants.dateFormat).format(date);
  }

  static String formatDateTime(DateTime? date, {String? format}) {
    if (date == null) return '';
    return DateFormat(format ?? AppConstants.dateTimeFormat).format(date);
  }

  static String formatTimeAgo(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
