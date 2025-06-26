import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import './payment_form_screen.dart';
// import '../services/transactions_queue.dart';

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
  final String? data = barcode.rawValue;

  if (data != null) {
    try {
      final Map<String, dynamic> parsed = jsonDecode(data);

      // Validate expected keys
      if (parsed.containsKey('name') && parsed.containsKey('phone')) {
        final String name = parsed['name'];
        final String phone = parsed['phone'];

        setState(() => _scanned = true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentFormScreen(name: name, phone: phone),
          ),
        );
      } else {
        throw const FormatException('Missing required fields');
      }
    } catch (e) {
      // Handles invalid JSON or missing keys
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('❌ Invalid QR Code'),
          content: const Text(
            'The scanned QR code does not match the expected format.\n'
            'Please make sure it was generated from this app.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _scanned = false);
                Navigator.pop(context);
              },
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
    return Scaffold(
      appBar: AppBar(title: const Text('📲 Scan to Pay')),
      body: MobileScanner(
        onDetect: _onDetect,
      ),
    );
  }
}
