import 'package:flutter/material.dart';
import 'package:waylo/components/currencySelector.dart';
import 'package:waylo/layouts/subPageLayout.dart';
import 'package:waylo/models/currency.dart';
import 'package:waylo/repositories/currency_repository_factory.dart';
import 'package:waylo/service/currency_service.dart';

class Currencyconvert extends StatefulWidget {
  const Currencyconvert({super.key});

  @override
  State<Currencyconvert> createState() => _CurrencyconvertState();
  
}

class _CurrencyconvertState extends State<Currencyconvert> {
  late final CurrencyService currencyService;
  late List<TextEditingController> amountControllers;

  final List<Currency> currencies = const [
    Currency(
      code: 'IDR',
      name: 'Indonesian Rupiah',
      symbol: 'Rp',
    ),
    Currency(
      code: 'KWD',
      name: 'Kuwaiti Dinar',
      symbol: 'KD',
    ),
    Currency(
      code: 'USD',
      name: 'US Dollar',
      symbol: r'$',
    ),
  ];

  late List<Currency> selectedCurrencies;
  late List<String> amounts;

  @override
  void initState() {
    super.initState();

    currencyService = CurrencyService(
      currencyRepository: CurrencyRepositoryFactory.create(),
    );

    selectedCurrencies = [
      currencies[0],
      currencies[1],
      currencies[2],
    ];

    amounts = ['0', '0', '0'];

    amountControllers = [
      TextEditingController(text: '0'),
      TextEditingController(text: '0'),
      TextEditingController(text: '0'),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    @override
    void dispose() {
      for (final controller in amountControllers) {
        controller.dispose();
      }

      super.dispose();
    }
    return SubPageLayout(
      title: "Currency Convert",
      content: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CurrencySelector(
              currencies: currencies,
              selectedCurrency: selectedCurrencies[index],
              amount: amounts[index],
              amountController: amountControllers[index],
              onChanged: (currency) {
                setState(() {
                  selectedCurrencies[index] = currency;
                });
              },
              onAmountChanged: (value) {
                setState(() {
                  amounts[index] = value;
                });
              },
            ),
          );
        }),
      ),
    );
  }
}