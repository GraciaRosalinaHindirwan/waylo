
import 'package:timezone/timezone.dart' as tz;

class TimeService {
  DateTime getCityTime(String timeZoneId) {
    final location = tz.getLocation(timeZoneId);
    return tz.TZDateTime.now(location);
  }
}
