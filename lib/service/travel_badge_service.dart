import '../models/travel_badge.dart';
import '../models/user_badge.dart';
import '../repositories/travel_badge_repository.dart';

class TravelBadgeService {
  final TravelBadgeRepository repository;

  // Menyimpan ID destinasi yang sudah dihitung selama aplikasi berjalan.
  final Map<int, Set<String>> _visitedDestinations = {};
  final Map<int, Set<String>> _visitedCategories = {};

  TravelBadgeService(this.repository);

  Future<List<TravelBadge>> getAllBadges() {
    return repository.getAllBadges();
  }

  Future<List<UserBadge>> getUserBadges(int userId) {
    return repository.getUserBadges(userId);
  }

  Future<void> recordDestinationVisit({
    required int userId,
    required String destinationId,
    required String destinationName,
    String? category,
  }) async {
    final visited = _visitedDestinations.putIfAbsent(
      userId,
      () => <String>{},
    );

    // Destinasi yang sama tidak dihitung dua kali.
    final isNewDestination = visited.add(destinationId);

    if (!isNewDestination) return;

    await _updateBadge(
      userId: userId,
      badgeId: 'china_starter',
      progress: 1,
    );

    await _updateBadge(
      userId: userId,
      badgeId: 'curious_explorer',
      progress: visited.length,
    );

    final normalizedName = destinationName.toLowerCase();

    if (normalizedName.contains('great wall')) {
      await _updateBadge(
        userId: userId,
        badgeId: 'great_wall_dreamer',
        progress: 1,
      );
    }

    if (normalizedName.contains('panda') ||
        normalizedName.contains('chengdu')) {
      await _updateBadge(
        userId: userId,
        badgeId: 'panda_fan',
        progress: 1,
      );
    }

    if (category != null) {
      final categories = _visitedCategories.putIfAbsent(
        userId,
        () => <String>{},
      );

      final normalizedCategory = category.toLowerCase();

      if (normalizedCategory == 'culture' ||
          normalizedCategory == 'history') {
        categories.add(destinationId);

        await _updateBadge(
          userId: userId,
          badgeId: 'culture_seeker',
          progress: categories.length,
        );
      }

      if (normalizedCategory == 'culinary' ||
          normalizedCategory == 'food') {
        await _updateBadge(
          userId: userId,
          badgeId: 'food_hunter',
          progress: categories
              .where((id) => id.startsWith('food:'))
              .length,
        );
      }
    }
  }

  Future<void> recordItineraryCreated(int userId) async {
    await _updateBadge(
      userId: userId,
      badgeId: 'ai_traveler',
      progress: 1,
    );
  }

  Future<void> _updateBadge({
    required int userId,
    required String badgeId,
    required int progress,
  }) async {
    final badges = await repository.getAllBadges();

    TravelBadge? badge;
    for (final item in badges) {
      if (item.id == badgeId) {
        badge = item;
        break;
      }
    }

    if (badge == null) return;

    final userBadges = await repository.getUserBadges(userId);

    UserBadge? previous;
    for (final item in userBadges) {
      if (item.badgeId == badgeId) {
        previous = item;
        break;
      }
    }

    if (previous?.isUnlocked == true) return;

    final currentProgress = progress;
    final unlocked = currentProgress >= badge.targetCount;

    await repository.saveUserBadge(
      UserBadge(
        userId: userId,
        badgeId: badgeId,
        progress: currentProgress > badge.targetCount
            ? badge.targetCount
            : currentProgress,
        isUnlocked: unlocked,
        unlockedAt: unlocked
            ? previous?.unlockedAt ?? DateTime.now()
            : null,
      ),
    );
  }
}
