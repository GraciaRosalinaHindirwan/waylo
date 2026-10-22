import '../../models/travel_badge.dart';
import '../../models/user_badge.dart';

abstract class TravelBadgeRepository {
  // Mengambil semua badge yang tersedia di WAYLO.
  Future<List<TravelBadge>> getAllBadges();

  // Mengambil data progres badge milik user.
  Future<List<UserBadge>> getUserBadges(int userId);

  // Menyimpan atau memperbarui progres badge milik user.
  Future<void> saveUserBadge(UserBadge userBadge);
}