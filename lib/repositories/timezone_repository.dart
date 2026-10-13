import 'package:waylo/models/timezone.dart';

abstract class TimezoneRepository {
  Future<List<Timezone>> getTimezones();
}