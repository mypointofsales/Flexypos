import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final Function(String) onScanned;

  const BarcodeScannerScreen({super.key, required this.onScanned});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Barcode")),
      body: MobileScanner(
        controller: _controller,
        onDetect: (barcodeCapture) {
          final List<Barcode> barcodes = barcodeCapture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (!_hasScanned && code != null && code.isNotEmpty) {
              _hasScanned = true;
              widget.onScanned(code);
              Navigator.pop(context);
              break;
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
