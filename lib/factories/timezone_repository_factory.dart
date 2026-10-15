import 'package:waylo/repositories/timezone_repository.dart';
import 'package:waylo/implementations/timezone_repository_impl.dart';

//mengembalikan objek yang memenuhi kontrak 
class TimezoneRepositoryFactory {
  static TimezoneRepository create() {
    return TimezoneRepositoryImpl();
  }
}