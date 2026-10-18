class UserBadge {
  final int userId;
  final String badgeId;
  final int progress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const UserBadge({
    required this.userId,
    required this.badgeId,
    this.progress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}
