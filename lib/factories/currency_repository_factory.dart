import 'package:waylo/repositories/currency_repository.dart';
import 'package:waylo/implementations/currency_repository_impl.dart';

class CurrencyRepositoryFactory {
  static CurrencyRepository create() {
    return CurrencyRepositoryImpl();
  }
}