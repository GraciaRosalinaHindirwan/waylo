import 'package:waylo/repositories/currency/currency_repository_impl.dart';
import 'package:waylo/repositories/currency/currency_repository.dart';

class CurrencyRepositoryFactory {
  static CurrencyRepository create() {
    return CurrencyRepositoryImpl();
  }
}