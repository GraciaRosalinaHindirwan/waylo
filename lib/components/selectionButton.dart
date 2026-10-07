import 'package:flutter/material.dart';
import 'package:waylo/theme/appColors.dart';

class SelectionButton extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String> onChanged;

  const SelectionButton({
    super.key,
    required this.options,
    required this.onChanged,
  });

  @override
  State<SelectionButton> createState() => _SelectionButtonState();
}

class _SelectionButtonState extends State<SelectionButton> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    // Other selalu ada
    final options = [
      ...widget.options.where((item) => item != 'Other'),
      'Other',
    ];

    return Wrap(
      spacing: 36,
      runSpacing: 18,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        final isOther = option == 'Other';

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedValue = option;
            });

            widget.onChanged(option);
          },
          child: Container(
            width: isOther ? 160 : 174,
            height: 91,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isOther
                      ? const Color(0xFFC4B79C)
                      : AppColors.secondary)
                  : (isOther
                      ? AppColors.border
                      : AppColors.card),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              option,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// makenya nanti gini 
// SelectionButton(
//   options: [
//     'Japan',
//     'Indonesia',
//     'South Korea',
//     'Thailand',
//     'China',
//   ],
//   onChanged: (value) {
//     print(value);
//   },
// ),