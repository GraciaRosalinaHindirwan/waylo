import 'package:flutter/material.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:waylo/theme/appColors.dart';

class Infochip extends StatelessWidget {
  final Widget? icon; 
  final String value; 
    final Color textColor; 

  const Infochip({
    super.key,
    this.icon,
    required this.value,
   this.textColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8, 
        vertical: 8, 
      ),

      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(100), 
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.8), 
            spreadRadius: 0.5, 
            blurRadius: 4, 
            offset: const Offset(0, 4), 
          ),
        ],
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min, 
        children: [
           if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],

          Text(
            value, 
            style: TextStyle(
              fontFamily: AppTextStyles.label.fontFamily,
              color: textColor, 
              fontSize: 16, 
            ),
          ),
        ],
      ),
    );
  }
}

// Cara pake nambahin location 
// Infochip(
//   icon: const Icon(
//     Icons.near_me_rounded,
//     size: 24,
//     color: AppColors.secondaryLight,
//   ),
//   value: 'Yogyakarta, Indonesia',
//   textColor: AppColors.textSecondary,
// )

// rating 
// Infochip(
//   icon: const Icon(
//     Icons.star_rounded,
//     size: 24,
//     color: AppColors.secondary,
//   ),
//   value: '4.8',
//   textColor: AppColors.textSecondary,
// )

//Category
// Infochip(
//   value: 'Cultural',
//   textColor: AppColors.textSecondary,
// )