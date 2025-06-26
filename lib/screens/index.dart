import 'package:flutter/material.dart';
import 'qr_scan_screen.dart';
// Import your QR generation screen here when available
// import 'qr_generate_screen.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OFFluuter Pay')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Send'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScanScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text('Receive'),
              onPressed: () {
                // Replace with your QR generation screen when implemented
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const QRGenerateScreen()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR Generation not implemented yet')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}