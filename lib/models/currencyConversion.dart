import 'package:waylo/models/currency.dart';

class CurrencyConversion {
  final Currency fromCurrency;
  final Currency toCurrency;
  final double amount;
  final double convertedAmount;
  final DateTime updatedAt;

  const CurrencyConversion({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.convertedAmount,
    required this.updatedAt,
  });
}