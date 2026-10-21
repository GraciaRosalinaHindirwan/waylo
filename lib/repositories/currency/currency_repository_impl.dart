
import 'dart:convert';

import 'package:http/http.dart' as http; //kirim requrest API melalui http 
import 'package:waylo/models/currency.dart';
import 'package:waylo/models/exchangeRate.dart';
import 'package:waylo/repositories/currency/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  @override
  Future<List<Currency>> getCurrencies() async {
    final url = Uri.parse(
      'https://api.frankfurter.dev/v2/currencies',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil daftar mata uang: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data.map((item) {
      final currency = item as Map<String, dynamic>;

      return Currency(
        code: currency['iso_code'] as String,
        name: currency['name'] as String,
        symbol: (currency['symbol'] as String?) ?? '',
      );
    }).toList();
  }

  @override
  Future<ExchangeRate> getExchangeRate({
    required Currency baseCurrency,
    required Currency targetCurrency,
  }) async { //initnya kayak future jadi nunggu dulu baru dijalanin 
    // Jika mata uang sama, kursnya 1.
    if (baseCurrency.code == targetCurrency.code) {
      return ExchangeRate(
        rate: 1,
        date: DateTime.now(),
      );
    }

    // Ambil kode mata uang dari objek Currency.
    final baseCode = baseCurrency.code.toLowerCase();
    final targetCode = targetCurrency.code.toLowerCase();

    // Mengubah teks URL menjadi objek Uri, 
    //agar bisa diberikan ke HTTP client. 
    //Baris ini belum mengirim permintaan ke server.    
    final url = Uri.parse(
      'https://api.frankfurter.dev/v2/rate/'
      '$baseCode/$targetCode',
    );

    // kirim ke API server, terus tunggu responsenya supaya kita bisa dapet datanya.
    final response = await http.get(url);

    // Periksa apakah request berhasil.
    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data kurs: ${response.statusCode}',
      );
    }

    // Ubah respons JSON menjadi Map.
    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    // Kembalikan data dalam bentuk model ExchangeRate.
    return ExchangeRate(
      rate: (data['rate'] as num).toDouble(),
      date: DateTime.parse(data['date'] as String),
    );
  }
}
