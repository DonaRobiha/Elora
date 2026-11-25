import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:elora_school/widgets/elora_components.dart';
import 'package:http/http.dart' as http;

import 'package:elora_school/theme/colors.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  final TextEditingController amountController = TextEditingController(
    text: '100000',
  );

  static const List<Map<String, dynamic>> _fallbackCurrencies = [
    {'code': 'IDR', 'name': 'Rupiah Indonesia', 'rate': 1.0},
    {'code': 'USD', 'name': 'Dolar Amerika', 'rate': 16000.0},
    {'code': 'EUR', 'name': 'Euro', 'rate': 17500.0},
    {'code': 'GBP', 'name': 'Pound Inggris', 'rate': 20500.0},
    {'code': 'JPY', 'name': 'Yen Jepang', 'rate': 107.0},
    {'code': 'SGD', 'name': 'Dolar Singapura', 'rate': 12000.0},
    {'code': 'AUD', 'name': 'Dolar Australia', 'rate': 10500.0},
    {'code': 'CNY', 'name': 'Yuan China', 'rate': 2200.0},
    {'code': 'SAR', 'name': 'Riyal Saudi', 'rate': 4300.0},
    {'code': 'MYR', 'name': 'Ringgit Malaysia', 'rate': 3700.0},
  ];

  List<Map<String, dynamic>> _currencies = _fallbackCurrencies;
  bool _isLoadingRates = false;
  String? _ratesError;
  DateTime? _ratesLastUpdated;

  String fromCurrency = 'IDR';
  String toCurrency = 'USD';
  double? result;

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _isLoadingRates = true;
      _ratesError = null;
    });
    try {
      final response = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/IDR'))
          .timeout(const Duration(seconds: 15));
      final decoded = jsonDecode(response.body);
      if (decoded['result'] == 'success') {
        final Map<String, dynamic> rawRates = Map<String, dynamic>.from(
          decoded['rates'],
        );
        final updated = <Map<String, dynamic>>[];
        const wantedCodes = [
          'IDR',
          'USD',
          'EUR',
          'GBP',
          'JPY',
          'SGD',
          'AUD',
          'CNY',
          'SAR',
          'MYR',
        ];
        const names = {
          'IDR': 'Rupiah Indonesia',
          'USD': 'Dolar Amerika',
          'EUR': 'Euro',
          'GBP': 'Pound Inggris',
          'JPY': 'Yen Jepang',
          'SGD': 'Dolar Singapura',
          'AUD': 'Dolar Australia',
          'CNY': 'Yuan China',
          'SAR': 'Riyal Saudi',
          'MYR': 'Ringgit Malaysia',
        };
        for (final code in wantedCodes) {
          final apiRate = (rawRates[code] as num?)?.toDouble();
          if (apiRate == null || apiRate == 0) continue;

          final rateInIdr = code == 'IDR' ? 1.0 : 1.0 / apiRate;
          updated.add({
            'code': code,
            'name': names[code] ?? code,
            'rate': rateInIdr,
          });
        }
        if (updated.isNotEmpty) {
          setState(() {
            _currencies = updated;
            _ratesLastUpdated = DateTime.now();
            if (!updated.any((c) => c['code'] == fromCurrency)) {
              fromCurrency = 'IDR';
            }
            if (!updated.any((c) => c['code'] == toCurrency)) {
              toCurrency = 'USD';
            }
          });
        }
      } else {
        setState(() => _ratesError = 'Menggunakan kurs cadangan.');
      }
    } catch (e) {
      debugPrint('CURRENCY RATE FETCH ERROR: $e');
      setState(() => _ratesError = 'Menggunakan kurs cadangan.');
    } finally {
      setState(() => _isLoadingRates = false);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void convertCurrency() {
    final amount = double.tryParse(
      amountController.text.replaceAll(',', '').trim(),
    );

    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal yang valid.')),
      );
      return;
    }

    final fromRate =
        _currencies.firstWhere(
              (currency) => currency['code'] == fromCurrency,
            )['rate']
            as double;

    final toRate =
        _currencies.firstWhere(
              (currency) => currency['code'] == toCurrency,
            )['rate']
            as double;

    setState(() {
      result = amount * fromRate / toRate;
    });
  }

  void swapCurrencies() {
    setState(() {
      final temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      result = null;
    });
  }

  String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: eloraBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConverterCard(),
                    const SizedBox(height: 14),
                    _buildCurrencyInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 82,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 10, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFBFE4DC), Color(0xFF86C6B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            color: const Color(0xFF173E3A),
          ),
          Expanded(
            child: Text(
              'Konversi Mata Uang',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF173E3A),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Muat ulang kurs',
            onPressed: _isLoadingRates ? null : _fetchRates,
            icon: _isLoadingRates
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF17665F),
                    ),
                  )
                : Icon(Icons.refresh_rounded, color: Color(0xFF17665F)),
          ),
          Icon(
            Icons.currency_exchange_rounded,
            color: Color(0xFF17665F),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildConverterCard() {
    return EloraCard(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nominal pembayaran',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: eloraDark,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Masukkan nominal',
              filled: true,
              fillColor: eloraBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final preset in [
                  100000,
                  500000,
                  1000000,
                  5000000,
                  50000000,
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ActionChip(
                      label: Text(
                        preset >= 1000000
                            ? '${preset ~/ 1000000} jt'
                            : '${preset ~/ 1000} rb',
                        style: TextStyle(
                          color: eloraPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      backgroundColor: eloraPrimary.withValues(alpha: 0.08),
                      side: BorderSide.none,
                      onPressed: () {
                        amountController.text = '$preset';
                        convertCurrency();
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Dari (asal)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: eloraDark,
            ),
          ),
          const SizedBox(height: 8),
          _buildCurrencyDropdown(
            value: fromCurrency,
            onChanged: (value) {
              setState(() {
                fromCurrency = value!;
                result = null;
              });
            },
          ),
          Center(
            child: IconButton(
              onPressed: swapCurrencies,
              icon: Icon(
                Icons.swap_vert_rounded,
                color: eloraPrimary,
                size: 28,
              ),
            ),
          ),
          Text(
            'Ke (tujuan)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: eloraDark,
            ),
          ),
          const SizedBox(height: 8),
          _buildCurrencyDropdown(
            value: toCurrency,
            onChanged: (value) {
              setState(() {
                toCurrency = value!;
                result = null;
              });
            },
          ),
          const SizedBox(height: 22),
          EloraPrimaryButton(
            label: 'Konversi Sekarang',
            onPressed: convertCurrency,
          ),
          if (result != null) ...[
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: eloraPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hasil estimasi',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$toCurrency ${formatAmount(result!)}',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: eloraPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: eloraBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: _currencies.map((currency) {
            return DropdownMenuItem<String>(
              value: currency['code'] as String,
              child: Text(
                '${currency['code']} - ${currency['name']}',
                style: TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCurrencyInfo() {
    String infoText;
    if (_isLoadingRates) {
      infoText = 'Memuat kurs terbaru…';
    } else if (_ratesError != null) {
      infoText =
          'Menggunakan kurs cadangan. Tekan muat ulang untuk mencoba lagi.';
    } else if (_ratesLastUpdated != null) {
      final h = _ratesLastUpdated!.hour.toString().padLeft(2, '0');
      final m = _ratesLastUpdated!.minute.toString().padLeft(2, '0');
      infoText = 'Kurs terbaru diperbarui pukul $h:$m.';
    } else {
      infoText = 'Kurs diperbarui saat halaman dibuka.';
    }

    return EloraCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: eloraPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              infoText,
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          if (_ratesError != null)
            TextButton(onPressed: _fetchRates, child: Text('Retry')),
        ],
      ),
    );
  }
}
