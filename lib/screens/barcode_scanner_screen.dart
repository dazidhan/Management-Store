import 'package:flutter/material.dart';
import '../widgets/barcode_scanner.dart';

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BarcodeScannerWidget(
      onScan: (barcode) {
        // Return barcode value to previous screen
        Navigator.pop(context, barcode);
      },
    );
  }
}



