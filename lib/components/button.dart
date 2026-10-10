
import 'package:flutter/material.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 54,
    this.borderRadius = 30,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? AppColors.secondary,
          foregroundColor: textColor ?? AppColors.card,
          elevation: 4,
          shadowColor: AppColors.textPrimary.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Text(
          text,
          style: AppTextStyles.button.copyWith(
            color: textColor ?? AppColors.card,
          ),
        ),
      ),
    );
  }
}


//cara pakai
// CustomButton(
//   text: 'Register',
//   onPressed: () {
//     debugPrint('Register ditekan');
//   },
// )