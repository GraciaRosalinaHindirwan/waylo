import 'package:waylo/theme/appColors.dart';
import 'package:flutter/material.dart';

class Inputfield extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const Inputfield({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,

            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textPrimary,
            ),

            decoration: InputDecoration(
              label: Container(
                color: AppColors.card,
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins-Regular',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              filled: true,
              fillColor: AppColors.card,

              // INI yang mengatur tinggi area input
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 17,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.card,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.card,
                ),
              ),
            ),
          ),

          // INNER SHADOW
          Positioned(
            top: 1,
            left: 1,
            right: 1,
            height: 8,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}