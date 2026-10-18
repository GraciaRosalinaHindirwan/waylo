import 'package:waylo/implementations/travel_badge_repository_impl.dart';
import 'package:waylo/repositories/travel_badge_repository.dart';

class TravelBadgeRepositoryFactory {
  static TravelBadgeRepository create() {
    return TravelBadgeRepositoryImpl();
  }
}
