import 'package:waylo/repositories/currency/currency_repository.dart';
import 'package:waylo/repositories/currency/currency_repository_impl.dart';

class CurrencyRepositoryFactory {
  static CurrencyRepository create() {
    return CurrencyRepositoryImpl();
  }
}