import '../models/travel_badge.dart';
import '../models/user_badge.dart';
import 'package:waylo/repositories/travel_badge_repository.dart';


class TravelBadgeRepositoryImpl implements TravelBadgeRepository {
  // Dummy data definisi badge WAYLO.
  
  // Dummy data definisi badge WAYLO.
  final List<TravelBadge> _badges = const [
    TravelBadge(
      id: 'china_starter',
      name: 'China Starter',
      description: 'Cari atau buka detail destinasi China pertama.',
      icon: 'explore',
      type: BadgeType.destinationVisit,
    ),
    TravelBadge(
      id: 'curious_explorer',
      name: 'Curious Explorer',
      description: 'Buka detail 5 destinasi China yang berbeda.',
      icon: 'travel_explore',
      targetCount: 5,
      type: BadgeType.destinationVisit,
    ),
    TravelBadge(
      id: 'culture_seeker',
      name: 'Culture Seeker',
      description: 'Buka detail 3 destinasi budaya atau sejarah.',
      icon: 'account_balance',
      targetCount: 3,
      type: BadgeType.categoryVisit,
    ),
    TravelBadge(
      id: 'great_wall_dreamer',
      name: 'Great Wall Dreamer',
      description: 'Cari atau buka detail Great Wall of China.',
      icon: 'landscape',
      type: BadgeType.specificDestination,
    ),
    TravelBadge(
      id: 'panda_fan',
      name: 'Panda Fan',
      description: 'Cari atau buka detail destinasi panda di Chengdu.',
      icon: 'pets',
      type: BadgeType.specificDestination,
    ),
    TravelBadge(
      id: 'food_hunter',
      name: 'Food Hunter',
      description: 'Buka detail 5 destinasi kuliner China yang berbeda.',
      icon: 'restaurant',
      targetCount: 5,
      type: BadgeType.categoryVisit,
    ),
    TravelBadge(
      id: 'ai_traveler',
      name: 'AI Traveler',
      description: 'Berhasil membuat itinerary menggunakan AI Trip Planner.',
      icon: 'auto_awesome',
      type: BadgeType.itineraryCreated,
    ),
  ];

  // Penyimpanan sementara progres badge per user.
  final Map<int, Map<String, UserBadge>> _userBadges = {};

  @override
  Future<List<TravelBadge>> getAllBadges() async {
    return List.unmodifiable(_badges);
  }

  @override
  Future<List<UserBadge>> getUserBadges(int userId) async {
    final badges = _userBadges[userId];

    if (badges == null) {
      return [];
    }

    return List.unmodifiable(badges.values);
  }

  @override
  Future<void> saveUserBadge(UserBadge userBadge) async {
    final userBadges = _userBadges.putIfAbsent(
      userBadge.userId,
      () => {},
    );

    userBadges[userBadge.badgeId] = userBadge;
  }
}
