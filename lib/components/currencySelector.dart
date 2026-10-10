
import 'package:flutter/material.dart';
import 'package:waylo/models/currency.dart';
import 'package:waylo/theme/appColors.dart';

class CurrencySelector extends StatelessWidget {
  final List<Currency> currencies;
  final Currency selectedCurrency;
  final ValueChanged<Currency> onChanged;

  const CurrencySelector({
    super.key,
    required this.currencies,
    required this.selectedCurrency,
    required this.onChanged,
  });

  @override
Widget build(BuildContext context) {
  return 
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kiri: IDR dan dropdown
        
      DropdownButtonHideUnderline(
        child: IntrinsicWidth(
          child: DropdownButton<Currency>(
            value: selectedCurrency,
            isDense: true,
            padding: EdgeInsets.zero,
            isExpanded: false,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFF5AD66),
              size: 30,
            ),
            items: currencies.map((currency) {
              return DropdownMenuItem<Currency>(
                value: currency,
                child: Text(
                  currency.code,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (currency) {
              if (currency != null) {
                onChanged(currency);
              }
            },
          ),
        ),
      ),


        // Kanan: angka dan nama mata uang
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              '1',
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                height: 1,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              selectedCurrency.name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
