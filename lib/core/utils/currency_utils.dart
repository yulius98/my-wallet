import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class CurrencyUtils {
  /// Parse currency string to double, removing commas
  static double parseAmount(String text) {
    String cleanText = text.replaceAll(',', '');
    return double.tryParse(cleanText) ?? 0.0;
  }

  /// Format double to currency string with comma separator
  static String formatAmount(double amount, {int decimals = 2}) {
    return toCurrencyString(
      amount.toStringAsFixed(decimals),
    );
  }

  /// Format currency for display in TextFormField
  static String formatCurrency(double amount) {
    return toCurrencyString(
      amount.toStringAsFixed(2),
      mantissaLength: 2,
      thousandSeparator: ThousandSeparator.Comma,
    );
  }

  /// Calculate allocation amount from income and percentage
  static double calculateAllocation(double income, double percentage) {
    return income * percentage;
  }

  /// Format and calculate allocation
  static String formatAllocation(double income, double percentage) {
    double amount = calculateAllocation(income, percentage);
    return formatAmount(amount);
  }
}
