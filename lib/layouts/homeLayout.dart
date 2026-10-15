import 'package:flutter/material.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';

class Homelayout extends StatelessWidget {
  final String greeting;
  final String title;
  final String subtitle;
  final Widget searchBar;
  final Widget content;
  final Widget? bottomNavigationBar;

  const Homelayout({
    super.key,
    required this.greeting,
    required this.title,
    required this.subtitle,
    required this.searchBar,
    required this.content,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Image.asset(
                      'assets/img/backgroundUp.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),

                  Positioned(
                    top: 24,
                    left: 28,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          title,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Hanya search bar yang menimpa gambar
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: -2,
                    child: searchBar,
                  ),
                ],
              ),

              // Konten lain dimulai di bawah gambar
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
