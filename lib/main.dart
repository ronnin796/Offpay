import 'package:flutter/material.dart';
import 'screens/qr_scan_screen.dart';

void main() {
  runApp(const OffPayApp());
}

class OffPayApp extends StatelessWidget {
  const OffPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OffPay',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const QRScanScreen(),
    );
  }
}
