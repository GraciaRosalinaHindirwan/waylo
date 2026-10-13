import 'package:timezone/timezone.dart' as tz;
import 'package:waylo/models/timezone.dart';
import 'package:waylo/repositories/timezone_repository.dart';

class TimezoneService {
  final TimezoneRepository timezoneRepository;

  TimezoneService({
    required this.timezoneRepository,
  });

  Future<List<Timezone>> getTimezones() {
    return timezoneRepository.getTimezones();
  }

  tz.TZDateTime getCurrentTime(Timezone timezone) {
    final location = tz.getLocation(timezone.timeZoneId);

    return tz.TZDateTime.now(location);
  }
}