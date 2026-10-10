import '../models/timezone.dart';

abstract class TimezoneRepository {
  Future<List<Timezone>> getAllTimezones();
}
