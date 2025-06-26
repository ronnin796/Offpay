import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerateScreen extends StatelessWidget {
  const QRGenerateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For demo, use static data. Replace with actual user/payment info.
    final String qrData = 'user:demo;amount:100';

    return Scaffold(
      appBar: AppBar(title: const Text('Receive Payment')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 220.0,
            ),
            const SizedBox(height: 24),
            const Text(
              'Show this QR to the sender',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}