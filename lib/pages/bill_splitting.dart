import 'dart:io';
import 'package:flutter/material.dart';
import 'package:banking4students/services/receipt_scanner_service.dart';
import 'package:banking4students/utility/camera_utils.dart';
import 'package:banking4students/components/main_button.dart';

class BillSplittingPage extends StatefulWidget {
  final bool autoScan;
  const BillSplittingPage({Key? key, this.autoScan = false}) : super(key: key);

  @override
  State<BillSplittingPage> createState() => _BillSplittingPageState();
}

class _BillSplittingPageState extends State<BillSplittingPage> {
  final List<Map<String, dynamic>> _items = []; // Scanned items list

  double _tipPercentage = 15.0;

  double get _subtotal {
    return _items.fold(0.0, (sum, item) {
      int qty = item['selectedQuantity'] as int;
      double unitPrice = item['unitPrice'] as double;
      return sum + qty * unitPrice;
    });
  }

  double get _tipAmount => _subtotal * (_tipPercentage / 100);
  double get _total => _subtotal + _tipAmount;

  Future<void> _scanReceipt() async {
    try {
      File? image = await CameraUtils.takePicture();
      if (image == null) {
        print("No image returned from CameraUtils.");
        return;
      }
      print("Image obtained: ${image.path}");
      dynamic scannedData = await ReceiptScannerService.scanReceipt(image);

      // If the returned data is a Map with an "items" key, extract the list.
      List<Map<String, dynamic>>? scannedItems;
      if (scannedData is Map && scannedData.containsKey("items")) {
        scannedItems = List<Map<String, dynamic>>.from(scannedData["items"]);
      } else if (scannedData is List) {
        scannedItems = List<Map<String, dynamic>>.from(scannedData);
      }

      if (scannedItems != null) {
        print("Scanned items: $scannedItems");
        setState(() {
          _items.clear();
          _items.addAll(
            scannedItems!.map(
              (item) => {
                "name": item["name"],
                "availableQuantity":
                    item["quantity"] is int
                        ? item["quantity"]
                        : int.tryParse(item["quantity"].toString()) ?? 0,
                "unitPrice": (item["unit_price"] as num).toDouble(),
                "selectedQuantity": 0,
              },
            ),
          );
        });
      } else {
        print("Scanned items returned null.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to scan receipt. Try again!")),
        );
      }
    } catch (e) {
      print("Error in _scanReceipt: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error scanning receipt: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.autoScan) {
      // Ensure that _scanReceipt is called after the widget is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scanReceipt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bill Splitting")),
      body: Column(
        children: [
          Expanded(
            child:
                _items.isEmpty
                    ? Center(
                      child: Text(
                        "No items added yet. Scan a receipt to begin!",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["name"],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text("Available: ${item["availableQuantity"]}"),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            setState(() {
                                              if (item["selectedQuantity"] >
                                                  0) {
                                                item["selectedQuantity"]--;
                                              }
                                            });
                                          },
                                        ),
                                        Text("${item["selectedQuantity"]}"),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              if (item["selectedQuantity"] <
                                                  item["availableQuantity"]) {
                                                item["selectedQuantity"]++;
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "MKD ${(item["selectedQuantity"] * item["unitPrice"]).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                MainButton(onTap: _scanReceipt, text: "Scan Receipt"),
                const SizedBox(height: 10),
                Text(
                  "Tip: ${_tipPercentage.toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: _tipPercentage,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: "${_tipPercentage.round()}%",
                  onChanged: (value) {
                    setState(() {
                      _tipPercentage = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSquareCard(label: "Tip", amount: _tipAmount),
                    _buildSquareCard(label: "Total", amount: _total),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareCard({required String label, required double amount}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.435,
      height: MediaQuery.of(context).size.width * 0.30,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "MKD ${amount.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
