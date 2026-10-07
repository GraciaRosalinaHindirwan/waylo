import 'package:waylo/theme/appColors.dart';
import 'package:flutter/material.dart';

class Inputfield extends StatelessWidget {
  final String label; 
  final TextEditingController controller;

  const Inputfield({
    super.key,
    required this.label,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),

      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Shadow bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 12,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Shadow bagian bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 12,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          TextField(
            controller: controller, 
            decoration: InputDecoration(
              labelText: label, 
              filled: true, 
              fillColor: AppColors.card, 
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
          
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.card, 
                ),
              ),
          
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.card,
                  width: 2, 
                ),
              ),
            ),
          ),
        ], 
      ), 
    );
  }
}