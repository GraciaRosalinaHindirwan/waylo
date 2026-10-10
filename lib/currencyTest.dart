
import 'package:flutter/material.dart';
import 'package:waylo/components/currencySelector.dart';
import 'package:waylo/dummy/currencyDummy.dart';
import 'package:waylo/models/currency.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() =>
      _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  late Currency selectedCurrency;

  @override
  void initState() {
    super.initState();
    selectedCurrency = currencyDummy.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: CurrencySelector(
            currencies: currencyDummy,
            selectedCurrency: selectedCurrency,
            onChanged: (currency) {
              setState(() {
                selectedCurrency = currency;
              });
            },
          ),
        ),
      ),
    );
  }
}
