import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class QRGenerateScreen extends StatefulWidget {
  const QRGenerateScreen({super.key});

  @override
  State<QRGenerateScreen> createState() => _QRGenerateScreenState();
}

class _QRGenerateScreenState extends State<QRGenerateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _qrData;

  void _generateQR() {
    if (_formKey.currentState!.validate()) {
      final data = jsonEncode({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      setState(() {
        _qrData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Your Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter phone number' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _generateQR,
                    child: const Text('Generate QR'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (_qrData != null) ...[
              QrImageView(
                data: _qrData!,
                version: QrVersions.auto,
                size: 220.0,
              ),
              const SizedBox(height: 16),
              const Text('Show this QR to the sender'),
            ],
          ],
        ),
      ),
    );
  }
}
