import 'package:waylo/models/currency.dart';
import 'package:waylo/models/currencyConversion.dart';

class CurrencyService {
  // Kurs dummy: nilai setiap mata uang terhadap 1 USD.
  // Ganti dengan kurs dari API ketika sudah tersedia.
  final Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'IDR': 16000.0,
    'KWD': 0.31,
  };

  CurrencyConversion convert({
    required Currency fromCurrency,
    required Currency toCurrency,
    required double amount,
  }) {
    if (amount < 0) {
      throw ArgumentError('Nominal tidak boleh negatif');
    }

    final fromRate = _exchangeRates[fromCurrency.code];
    final toRate = _exchangeRates[toCurrency.code];

    if (fromRate == null || toRate == null) {
      throw Exception('Kurs mata uang tidak tersedia');
    }

    // Konversi melalui USD sebagai mata uang dasar.
    final amountInUsd = amount / fromRate;
    final convertedAmount = amountInUsd * toRate;

    return CurrencyConversion(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: amount,
      convertedAmount: convertedAmount,
      updatedAt: DateTime.now(),
    );
  }
}