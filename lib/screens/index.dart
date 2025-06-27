// 🔹 screens/index.dart
import 'package:flutter/material.dart';
import 'qr_generate_screen.dart';
import 'qr_scan_screen.dart';
import '../services/transactions_history_screen.dart';
import './bluetooth_receiver.dart';
import './bluetooth_sender.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('OFFluuter Pay', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Logo/Icon
            CircleAvatar(
              radius: 44,
              backgroundColor: colorScheme.primary.withOpacity(0.08),
              child: Icon(Icons.offline_bolt, size: 48, color: colorScheme.primary),
            ),
            const SizedBox(height: 18),
            const Text(
              'Welcome to OFFluuter Pay',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Send and receive payments instantly,\neven without internet.',
              style: TextStyle(fontSize: 15, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            // Buttons
            Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Receive (Generate QR)'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QRGenerateScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Send (Scan QR)'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QRScanScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('Transaction History'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: colorScheme.primary,
                    textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                    side: BorderSide(color: colorScheme.primary, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionsHistoryScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReceiverBluetoothServerScreen()),
                  ),
                  child: const Text('Receive Payment via Bluetooth'),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Made with Flutter • Offline Ready',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
