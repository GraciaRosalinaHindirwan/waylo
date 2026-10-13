import 'package:waylo/repositories/timezone_repository.dart';
import 'package:waylo/repositories/timezone_repository_impl.dart';

class TimezoneRepositoryFactory {
  static TimezoneRepository create() {
    return TimezoneRepositoryImpl();
  }
}