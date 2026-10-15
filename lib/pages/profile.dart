import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waylo/pages/login_page.dart';
import 'package:waylo/service/auth_service.dart';

import 'package:waylo/components/profileCard.dart';
import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/models/user.dart';
import 'package:waylo/pages/explorePage.dart';
import 'package:waylo/pages/favorite.dart';
import 'package:waylo/pages/home.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:waylo/pages/currencyConvertPage.dart';
import 'package:waylo/pages/timezoneConvertPage.dart';
import 'package:waylo/pages/aboutMobile.dart';

class ProfilePage extends StatelessWidget {

  const ProfilePage({super.key});

  Widget buildHeader() {
    return SizedBox(
      height: 40,
      child: Center(
        child: Text(
          'MY PROFILE',
          textAlign: TextAlign.center,
          style: AppTextStyles.heading3.copyWith(color: Colors.black),
        ),
      ),
    );
  }

  
Widget buildAvatar(User? user) {
  return Column(
    spacing: 8,
    children: [
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            width: 5,
            color: AppColors.border,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.person_outline,
            size: 42,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      Column(
        spacing: 4,
        children: [
          Text(
            user?.fullname ?? 'Belum login',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            user?.username != null
                ? '@${user!.username}'
                : '@username',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ],
  );
}


  Widget buildLogout(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17.06),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(106.61),
          border: Border.all(width: 1, color: AppColors.accent),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4.26,
              offset: Offset(4.26, 4.26),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10.66,
          children: [
            const Icon(Icons.logout, size: 24, color: AppColors.accent),
            Text(
              'Logout',
              style: AppTextStyles.button.copyWith(
                color: AppColors.accent,
                fontSize: 14.93,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
                child: Column(
                  spacing: 16,
                  children: [
                    buildHeader(),
                    buildAvatar(user),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        spacing: 24,
                        children: [
                          Column(
                            spacing: 4,
                            children: [
                              ProfileCard(
                                title: 'Favorite Place',
                                icon: Icons.favorite_border,
                                page: FavoritePage(),
                              ),
                               ProfileCard(
                                title: 'Travel Badges',
                                icon: Icons.military_tech_outlined,
                                page: _PlaceholderPage('Travel Badges'),
                              ),
                            ],
                          ),
                          Column(
                            spacing: 4,
                            children:  [
                              ProfileCard(
                                title: 'Currency Convert',
                                icon: Icons.currency_exchange,
                                page: Currencyconvertpage(),
                              ),
                              ProfileCard(
                                title: 'Local Time Convert',
                                icon: Icons.access_time,
                                page: Timezoneconvertpage(),
                              ),
                            ],
                          ),
                          Column(
                            spacing: 4,
                            children:  [
                              ProfileCard(
                                title: 'Notification',
                                icon: Icons.notifications,
                                page: _PlaceholderPage('Notification'),
                              ),
                              ProfileCard(
                                title: 'About Mobile',
                                icon: Icons.info,
                                page: AboutMobilePage(),
                              ),
                            ],
                          ),
                          buildLogout(context),
                        ],
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Explorepage(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// buat sementara nnti ganti ke page kl udh dibuat
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
