import 'package:waylo/models/currency.dart';
import 'package:waylo/models/currencyConversion.dart';
import 'package:waylo/repositories/currency_repository.dart';

class CurrencyService {
  final CurrencyRepository currencyRepository;

  CurrencyService({
    required this.currencyRepository,
  });

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