import 'dart:io';
import 'package:flutter/material.dart';
import 'package:banking4students/services/receipt_scanner_service.dart';
import 'package:banking4students/utility/camera_utils.dart';

class BillSplittingInkWell extends StatefulWidget {
  const BillSplittingInkWell({Key? key}) : super(key: key);

  @override
  State<BillSplittingInkWell> createState() => _BillSplittingInkWellState();
}

class _BillSplittingInkWellState extends State<BillSplittingInkWell> {
  final List<Map<String, dynamic>> _items = [];
  double _tipPercentage = 15.0;

  double get _subtotal {
    return _items.fold(0.0, (sum, item) {
      final qty = item['selectedQuantity'] as int;
      final unitPrice = item['unitPrice'] as double;
      return sum + (qty * unitPrice);
    });
  }

  double get _tipAmount => _subtotal * (_tipPercentage / 100);
  double get _total => _subtotal + _tipAmount;

  Future<void> _scanReceipt() async {
    try {
      // 1. Use CameraUtils to capture an image.
      final File? image = await CameraUtils.takePicture();
      if (image == null) {
        debugPrint("No image returned from CameraUtils.");
        return;
      }

      // 2. Scan the receipt using your ReceiptScannerService.
      final List<Map<String, dynamic>>? scannedItems =
          await ReceiptScannerService.scanReceipt(image);

      // 3. If items are found, store them in the state.
      if (scannedItems != null) {
        setState(() {
          _items.clear();
          _items.addAll(
            scannedItems.map(
              (item) => {
                "name": item["name"],
                "availableQuantity": item["quantity"] is int
                    ? item["quantity"]
                    : int.tryParse(item["quantity"].toString()) ?? 0,
                "unitPrice": (item["unit_price"] as num).toDouble(),
                "selectedQuantity": 0,
              },
            ),
          );
        });
      } else {
        debugPrint("Scanned items returned null.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to scan receipt. Try again!")),
        );
      }
    } catch (e) {
      debugPrint("Error in _scanReceipt: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error scanning receipt: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _scanReceipt,
      // For visual clarity, wrap the content in a Container or Card
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        // If no items yet, show a simple prompt. Otherwise, show the items list.
        child: _items.isEmpty
            ? const Text(
                "Tap here to scan a receipt!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Scanned Items:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // List of items
                  Expanded(
                    child: ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["name"],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text("Available: ${item["availableQuantity"]}"),
                                const SizedBox(height: 6),
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
                                              if (item["selectedQuantity"] > 0) {
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
                  const SizedBox(height: 10),
                  // Tip slider and total display
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
    );
  }

  Widget _buildSquareCard({required String label, required double amount}) {
    final cardWidth = MediaQuery.of(context).size.width * 0.4;

    return Container(
      width: cardWidth,
      height: cardWidth * 0.6, // keep a rectangular shape
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 22,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "MKD ${amount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
