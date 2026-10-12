import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final NumberFormat _numberFormat = NumberFormat(
    '#,##0.###',
    'de_DE',
  );

  late final CurrencyService currencyService;
  late final List<TextEditingController> amountControllers;

  int _conversionRequestId = 0;
  int _sourceIndex = 0;

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

  // Mengambil daftar mata uang dari API
  Future<void> loadCurrencies() async {
    try {
      final repository = CurrencyRepositoryFactory.create();
      final result = await repository.getCurrencies();

      final initialCurrencies = <Currency>[];

      for (final code in ['IDR', 'KWD', 'USD']) {
        final matches = result.where((c) => c.code == code);

        if (matches.isEmpty) {
          throw Exception('Mata uang $code tidak ditemukan');
        }

        initialCurrencies.add(matches.first);
      }

      if (!mounted) return;

      setState(() {
        currencies = result;
        selectedCurrencies = initialCurrencies;
        isLoadingCurrencies = false;
        currencyError = null;
      });
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

  // Menghitung nominal pada dua mata uang lainnya
  Future<void> convertAmounts(int sourceIndex, String value) async {
    final requestId = ++_conversionRequestId;
    _sourceIndex = sourceIndex;

    final normalizedValue = value
    .replaceAll('.', '')
    .replaceAll(',', '.')
    .trim();

    final amount = double.tryParse(normalizedValue);

    setState(() {
      amounts[sourceIndex] = value;
    });

    // Jika input kosong atau tidak valid, kosongkan hasil lainnya.
    if (amount == null) {
      setState(() {
        for (int i = 0; i < 3; i++) {
          if (i == sourceIndex) continue;

          amounts[i] = '';
          amountControllers[i].clear();
        }
      });
      return;
    }

    // Hitung ulang dua mata uang lainnya.
    for (int i = 0; i < 3; i++) {
      if (i == sourceIndex) continue;

      try {
        final result = await currencyService.convert(
          fromCurrency: selectedCurrencies[sourceIndex],
          toCurrency: selectedCurrencies[i],
          amount: amount,
        );

        // Abaikan hasil request yang sudah kedaluwarsa.
        if (!mounted || requestId != _conversionRequestId) {
          return;
        }

        final formatted = _numberFormat.format(
          result.convertedAmount,
        );

        setState(() {
          amounts[i] = formatted;

          amountControllers[i].value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(
              offset: formatted.length,
            ),
          );
        });
      } catch (e) {
        debugPrint(
          'Gagal mengonversi ke ${selectedCurrencies[i].code}: $e',
        );
      }
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

            // Jika dropdown berubah, hitung ulang hasilnya.
            onChanged: (currency) {
              setState(() {
                selectedCurrencies[index] = currency;
              });

              convertAmounts(
                _sourceIndex,
                amountControllers[_sourceIndex].text,
              );
            },

            // Jika nominal berubah, konversi otomatis.
            onAmountChanged: (value) {
              convertAmounts(index, value);
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