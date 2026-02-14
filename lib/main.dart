import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CurrencyApp());
}

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CurrencyHomePage(),
    );
  }
}

class CurrencyHomePage extends StatefulWidget {
  const CurrencyHomePage({super.key});

  @override
  State<CurrencyHomePage> createState() => _CurrencyHomePageState();
}

class _CurrencyHomePageState extends State<CurrencyHomePage> {
  final TextEditingController amountController = TextEditingController();

  double result = 0.0;
  bool isLoading = false;

  String fromCurrency = "USD";
  String toCurrency = "INR";

  Map<String, dynamic> exchangeRates = {};

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  Future<void> fetchRates() async {
    setState(() {
      isLoading = true;
    });

    final url =
        Uri.parse("https://api.exchangerate-api.com/v4/latest/USD");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        exchangeRates = data["rates"];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void convertCurrency() {
    double amount = double.tryParse(amountController.text) ?? 0;

    if (exchangeRates.isEmpty) return;

    double fromRate = (exchangeRates[fromCurrency] as num).toDouble();
    double toRate = (exchangeRates[toCurrency] as num).toDouble();


    double usdAmount = amount / fromRate;
    double converted = usdAmount * toRate;

    setState(() {
      result = converted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencies = exchangeRates.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Currency Converter"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    color: const Color(0xFF1E293B),
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Convert Currency",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Enter amount",
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon:
                                  const Icon(Icons.attach_money),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: fromCurrency,
                                  decoration: InputDecoration(
                                    labelText: "From",
                                    filled: true,
                                    fillColor:
                                        const Color(0xFF0F172A),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: currencies
                                      .map((currency) =>
                                          DropdownMenuItem(
                                            value: currency,
                                            child: Text(currency),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      fromCurrency = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: toCurrency,
                                  decoration: InputDecoration(
                                    labelText: "To",
                                    filled: true,
                                    fillColor:
                                        const Color(0xFF0F172A),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: currencies
                                      .map((currency) =>
                                          DropdownMenuItem(
                                            value: currency,
                                            child: Text(currency),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      toCurrency = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: convertCurrency,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Convert",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          Container(
                            padding:
                                const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Converted Amount",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  result.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Colors.deepPurpleAccent,
                                  ),
                                ),
                                Text(
                                  toCurrency,
                                  style: const TextStyle(
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
