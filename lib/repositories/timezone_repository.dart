import 'package:waylo/models/timezone.dart';

//ini kontraknya, setiap class yang implementasi dia wajib punya method getTimeZone
abstract class TimezoneRepository {
  Future<List<Timezone>> getTimezones();
}