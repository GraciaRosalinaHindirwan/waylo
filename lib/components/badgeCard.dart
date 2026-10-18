import 'package:waylo/theme/app_text_styles.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:flutter/material.dart';

class BadgeCard extends StatelessWidget {
  final String icon;
  final String label;

  const BadgeCard({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 110,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 4,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Image.asset(
              icon,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.border,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
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
    );
  }
}