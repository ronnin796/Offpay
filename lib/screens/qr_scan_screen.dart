// 🔹 screens/qr_scan_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'payment_form_screen.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _scanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;

    final data = capture.barcodes.first.rawValue;
    if (data != null) {
      try {
        final Map<String, dynamic> parsed = jsonDecode(data);
        if (parsed.containsKey('name') && parsed.containsKey('phone') && parsed.containsKey('expected_amount')) {
          setState(() => _scanned = true);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentFormScreen(
                name: parsed['name'],
                phone: parsed['phone'],
                expectedAmount: parsed['expected_amount'].toDouble(),
              ),
            ),
          );
        } else {
          throw const FormatException('Missing fields');
        }
      } catch (_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Invalid QR'),
            content: const Text('This QR code is not valid for Bina Net payments.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan to Pay'), centerTitle: true),
      body: Container(
        color: colorScheme.surface,
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Scan Receiver\'s QR',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MobileScanner(onDetect: _onDetect),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}