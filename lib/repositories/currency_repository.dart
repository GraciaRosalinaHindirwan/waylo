import 'package:waylo/models/currency.dart';
import 'package:waylo/models/exchangeRate.dart';

//interface alias kontrak untuk mengambil data nilai tukar mata uang dari sumber data.

abstract class CurrencyRepository {
  Future<ExchangeRate> getExchangeRate({
    required Currency baseCurrency,
    required Currency targetCurrency,
  });
}