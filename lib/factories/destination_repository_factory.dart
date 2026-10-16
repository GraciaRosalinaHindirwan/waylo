import 'package:waylo/repositories/destination_repository.dart';
import 'package:waylo/implementations/destination_repository_impl.dart';

class DestinationRepositoryFactory {
  static DestinationRepository create() {
    return DestinationRepositoryImpl();
  }
}