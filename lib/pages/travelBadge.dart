import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waylo/components/badgeCard.dart';
import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/models/travel_badge.dart';
import 'package:waylo/models/user_badge.dart';
import 'package:waylo/pages/explorePage.dart';
import 'package:waylo/pages/home.dart';
import 'package:waylo/repositories/badge/travel_badge_repository_factory.dart';
import 'package:waylo/service/auth_service.dart';
import 'package:waylo/service/travel_badge_service.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waylo/service/session_storage.dart';

class TravelBadgePage extends StatefulWidget {
  const TravelBadgePage({super.key});

  @override
  State<TravelBadgePage> createState() => _TravelBadgePageState();
}

class _TravelBadgePageState extends State<TravelBadgePage> {
  late final TravelBadgeService _travelBadgeService;

  List<TravelBadge> badges = [];
  List<UserBadge> userBadges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final repository = TravelBadgeRepositoryFactory.create(
      Supabase.instance.client,
      SessionStorage(),
    );

    _travelBadgeService = TravelBadgeService(repository);
    loadBadges();
  }

  Future<void> loadBadges() async {
    try {
      final userId = context.read<AuthService>().currentUser?.id;

      final allBadges = await _travelBadgeService.getAllBadges();
      debugPrint('TOTAL BADGES: ${allBadges.length}');

      final allUserBadges = userId != null
          ? await _travelBadgeService.getUserBadges(userId)
          : <UserBadge>[];

      debugPrint('TOTAL USER BADGES: ${allUserBadges.length}');

      if (!mounted) return;

      setState(() {
        badges = allBadges;
        userBadges = allUserBadges;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat badge: $e'),
        ),
      );
    }
  }

  UserBadge? findUserBadge(String badgeId) {
    for (final userBadge in userBadges) {
      if (userBadge.badgeId == badgeId) {
        return userBadge;
      }
    }
    return null;
  }

  Widget buildHeader() {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              'Travel Badges',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading3.copyWith(color: Colors.black),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : badges.isEmpty
                              ? Center(
                                  child: Text(
                                    'Belum ada badge',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 10,
                                    mainAxisExtent: 145,
                                  ),
                                  itemCount: badges.length,
                                  itemBuilder: (context, index) {
                                    final badge = badges[index];
                                    final userBadge = findUserBadge(badge.id);
                                    final isUnlocked =
                                        userBadge?.isUnlocked ?? false;
                                    final progress = userBadge?.progress ?? 0;

                                    debugPrint(
                                      'BADGE: ${badge.name} | '
                                      'ICON: ${badge.icon} | '
                                      'UNLOCKED: $isUnlocked | '
                                      'PROGRESS: $progress/${badge.targetCount}',
                                    );

                                    return BadgeCard(
                                      icon: badge.icon,
                                      label: isUnlocked
                                          ? badge.name
                                          : '$progress/${badge.targetCount}',
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          CustomBottomNavBar(
            currentIndex: 2,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              } else if (index == 1) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Explorepage()),
                  (route) => false,
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}