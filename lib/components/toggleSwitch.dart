
import 'package:waylo/theme/appColors.dart';
import 'package:flutter/material.dart';

class ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ToggleSwitch({
    super.key,
    required this.value,
    this.onChanged,
  });

  static const Duration duration = Duration(milliseconds: 300);
  static const Curve curve = Cubic(0, 0, 0.58, 1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        width: 40,
        height: 24,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            width: 1,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: duration,
              curve: curve,
              left: value ? 18 : 2,
              top: 2,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
