import 'package:waylo/models/currency.dart';
import 'package:waylo/models/currencyConversion.dart';
import 'package:waylo/repositories/currency_repository.dart';

class CurrencyService {
  final CurrencyRepository currencyRepository;

  CurrencyService({
    required this.currencyRepository,
  });

  // Mengambil daftar mata uang dari repository.
  Future<List<Currency>> getCurrencies() {
    return currencyRepository.getCurrencies();
  }

    // Menentukan mata uang default untuk tiga card.
  List<Currency> getInitialCurrencies(
    List<Currency> currencies,
  ) {
    const defaultCodes = ['IDR', 'KWD', 'USD'];

    return defaultCodes.map((code) {
      return currencies.firstWhere(
        (currency) => currency.code == code,
        orElse: () => throw Exception(
          'Mata uang $code tidak ditemukan',
        ),
      );
    }).toList();
  }

  Future<CurrencyConversion> convert({
    required Currency fromCurrency,
    required Currency toCurrency,
    required double amount,
  }) async {
    //mengambil kurs dari repository 
    final exchangeRate =
        await currencyRepository.getExchangeRate( //ada await karena ngambil data butuh waktu
      baseCurrency: fromCurrency,
      targetCurrency: toCurrency,
    );

    final convertedAmount = amount * exchangeRate.rate;

    return CurrencyConversion(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: amount,
      convertedAmount: convertedAmount,
      updatedAt: exchangeRate.date,
    );
  }
}