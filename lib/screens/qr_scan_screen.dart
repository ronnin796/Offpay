import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/transactions_queue.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _scanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;

    final Barcode barcode = capture.barcodes.first;
    final String? data = barcode?.rawValue;

    if (data != null) {
      setState(() => _scanned = true);
      TransactionQueue.queue({
        'method': 'QR',
        'amount': 100,
        'qrData': data,
        'timestamp': DateTime.now().toIso8601String(),
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('QR Scanned'),
          content: Text('Data: $data\nTransaction Queued.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _scanned = false);
                Navigator.pop(context);
              },
              child: const Text('Scan Again'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📲 Scan to Pay')),
      body: MobileScanner(
        onDetect: _onDetect,
      ),
    );
  }
}
