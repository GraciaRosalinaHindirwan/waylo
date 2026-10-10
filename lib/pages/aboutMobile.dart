
import 'package:flutter/material.dart';
import '../theme/appColors.dart';
import '../theme/app_text_styles.dart';
import '../components/buttomNav.dart';

class AboutMobilePage extends StatelessWidget {
  const AboutMobilePage({super.key});

  static const String backgroundAsset =
      '../assets/img/backgroundUp.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ilustrasi pemandangan di bagian bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Image.asset(
                backgroundAsset,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 24, 30),
                  child: Row(
                    children: [
                      Material(
                        color: AppColors.card,
                        shape: const CircleBorder(),
                        elevation: 1,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.pop(context),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.accent,
                              size: 21,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Text(
                          'About Mobile',
                          style: AppTextStyles.heading2.copyWith(
                            fontFamily: 'Fraunces',
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Accordion menu
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 180),
                    children: const [
                      AboutSection(
                        title: 'Application Version',
                        content: 'WAYLO Mobile • Version 1.0.0',
                      ),
                      AboutSection(
                        title: 'How to use',
                        content:
                            'Cari destinasi yang ingin kamu kunjungi, '
                            'lihat informasi tempat, dan temukan inspirasi '
                            'perjalanan melalui WAYLO.',
                      ),
                      AboutSection(
                        title: 'Privacy Police',
                        content:
                            'Informasi pengguna digunakan untuk mendukung '
                            'fungsi aplikasi. Kebijakan privasi lengkap '
                            'akan tersedia di bagian ini.',
                      ),
                      AboutSection(
                        title: 'App info',
                        content:
                            'WAYLO membantu pengguna menemukan informasi '
                            'destinasi dan menjelajahi tempat menarik.',
                      ),
                      AboutSection(
                        title: 'Feedback PAM',
                        content:
                            'terus terang saya tidak diberitahu, saya tidak '
                            'tahu, dan saya bahkan bertanya-tanya, kenapa '
                            'kok saya tidak diberitahu sampai hari ini',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Gunakan bottom navigation yang sudah ada
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          // Hubungkan ke halaman Home atau Explore milikmu.
        },
      ),
    );
  }
}

class AboutSection extends StatefulWidget {
  final String title;
  final String content;

  const AboutSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(
          left: 0,
          right: 12,
          bottom: 18,
        ),
        visualDensity: const VisualDensity(vertical: 1),
        onExpansionChanged: (expanded) {
          setState(() => isExpanded = expanded);
        },
        trailing: Icon(
          isExpanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          color: AppColors.secondaryLight,
          size: 30,
        ),
        title: Text(
          widget.title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.content,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
