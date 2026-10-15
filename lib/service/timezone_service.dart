import 'package:timezone/timezone.dart' as tz; //package untuk mendapatkanw waktu berdasarkan zona waktu 
import 'package:waylo/models/timezone.dart';
import 'package:waylo/repositories/timezone_repository.dart';

class TimezoneService {
  final TimezoneRepository timezoneRepository;

  TimezoneService({
    required this.timezoneRepository, 
    //service ini butuh objek yang memenuhi kontrak yang ada di repository
  });

  // Mengambil seluruh data zona waktu dari repository.
  Future<List<Timezone>> getTimezones() {
    return timezoneRepository.getTimezones(); //manggil method yang ada di repository 
  }

  // Mengambil waktu saat ini berdasarkan zona waktu.
  tz.TZDateTime getCurrentTime(Timezone timezone) {
    final location = tz.getLocation(timezone.timeZoneId);
    return tz.TZDateTime.now(location);
  }

  // Memfilter zona waktu yang valid dan mengecualikan Jakarta.
  Future<List<Timezone>> getAvailableTimezones() async {
    final result = await getTimezones(); //ambil data 

    return result.where((timezone) {
      if (timezone.timeZoneId == 'Asia/Jakarta') {
        return false;
      } //kecuali jakarta 

      try {
        tz.getLocation(timezone.timeZoneId); //id nya dikenali atau tidak 
        return true;
      } catch (_) {
        return false;
      }
    }).toList(); //buat daftar baru 
  }

  // Mencari zona waktu berdasarkan ID.
  Timezone? findTimezone(
    List<Timezone> timezones,
    String timeZoneId,
  ) {
    for (final timezone in timezones) {
      if (timezone.timeZoneId == timeZoneId) {
        return timezone;
      }
    }

    return null;
  }

  // Menentukan tiga zona waktu default dan mengisi fallback.
  List<Timezone?> getDefaultTimezones(
    List<Timezone> availableTimezones,
  ) {
    final selected = <Timezone?>[
      findTimezone(availableTimezones, 'Asia/Tokyo'),
      findTimezone(availableTimezones, 'Asia/Seoul'),
      findTimezone(availableTimezones, 'Europe/London'),
    ];

    //proses fallback 
    for (var i = 0; i < selected.length; i++) {
      if (selected[i] != null) continue;

      for (final timezone in availableTimezones) {
        final alreadyUsed = selected.any(
          (item) =>
              item?.timeZoneId == timezone.timeZoneId,
        );

        if (!alreadyUsed) {
          selected[i] = timezone;
          break;
        }
      }
    }

    return selected;
  }

  //mengecek ketersediaan data 
  bool hasAvailableTimezones({
    required List<Timezone> timezones,
    required List<Timezone?> selectedTimezones,
  }) {
    return timezones.isNotEmpty &&
        selectedTimezones.isNotEmpty &&
        selectedTimezones.any(
          (timezone) => timezone != null,
        );
  }
}
