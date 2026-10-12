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
  late final List<TextEditingController> amountControllers;

  List<Currency> currencies = [];
  List<Currency> selectedCurrencies = [];
  List<String> amounts = ['0', '0', '0'];

  bool isLoadingCurrencies = true;
  String? currencyError;

  @override
  void initState() {
    super.initState();

    final currencyRepository = CurrencyRepositoryFactory.create();

    currencyService = CurrencyService(
      currencyRepository: currencyRepository,
    );

    amountControllers = List.generate(
      3,
      (_) => TextEditingController(text: '0'),
    );

    loadCurrencies();
  }

  Future<void> loadCurrencies() async {
    try {
      debugPrint('1. Mulai mengambil mata uang');

      final repository = CurrencyRepositoryFactory.create();

      debugPrint('2. Repository berhasil dibuat');

      final result = await repository.getCurrencies();

      debugPrint('3. Jumlah mata uang: ${result.length}');

      if (!mounted) return;

      final initialCurrencies = <Currency>[];

      for (final code in ['IDR', 'KWD', 'USD']) {
        final matches = result.where((c) => c.code == code);

        if (matches.isEmpty) {
          throw Exception('Mata uang $code tidak ditemukan');
        }

        initialCurrencies.add(matches.first);
      }

      setState(() {
        currencies = result;
        selectedCurrencies = initialCurrencies;
        isLoadingCurrencies = false;
        currencyError = null;
      });

      debugPrint('4. Mata uang berhasil dimuat');
    } catch (e, stackTrace) {
      debugPrint('ERROR CURRENCY: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        currencyError = e.toString();
        isLoadingCurrencies = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPageLayout(
      title: 'Currency Convert',
      content: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoadingCurrencies) {
      return const Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (currencyError != null) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                currencyError!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoadingCurrencies = true;
                    currencyError = null;
                  });
                  loadCurrencies();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
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
    );
  }

  @override
  void dispose() {
    for (final controller in amountControllers) {
      controller.dispose();
    }

    super.dispose();
  }
}