import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeService {
  static Future<String?> scanBarcode(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
  }
}

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool scanned = false;
  final MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Barcode")),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) async {
          if (scanned) {
            print("Ignored extra detection");
            return;
          }

          final barcode = capture.barcodes.first.rawValue;
          print("===== BARCODE DETECTED =====");
          print("scanned before: $scanned");
          print("barcode rawValue: $barcode");

          scanned = true;

          // Must stop camera or else Android texture crashes
          await controller.stop();
          await Future.delayed(const Duration(milliseconds: 150));
          
          print("Returning barcode and closing scanner page");
          if (mounted) Navigator.pop(context, barcode);
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
