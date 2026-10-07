import 'package:waylo/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class BadgeCard extends StatelessWidget {
  final String icon;
  final String label;
  final Widget page;

  const BadgeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        width: 108,
        height: 110,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            Container(
              width: 80,
              height: 80,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(color: Color(0xFFD9D9D9)),
              child: Image.asset(
                icon,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}