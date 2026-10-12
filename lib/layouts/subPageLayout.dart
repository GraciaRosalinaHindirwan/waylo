import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class SubPageLayout extends StatelessWidget {
  final String title;
  final Widget content;

  const SubPageLayout({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tetap seperti kode kamu sebelumnya
          Container(
            width: double.infinity,
            height: 124,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 32,
              children: [
                GestureDetector(
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
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Area konten dan gambar bawah
          Expanded(
            child: Stack(
              children: [
                // Layer 1: Gambar dekorasi di paling bawah
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/img/backgroundDown.png',
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Layer 2: Konten berada di atas gambar
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: content,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}