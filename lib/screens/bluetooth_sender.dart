// bluetooth_transaction_screen.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/transactions_queue.dart';

class BluetoothTransactionScreen extends StatefulWidget {
  final String receiverName;
  final String receiverPhone;
  final double amount;

  const BluetoothTransactionScreen({
    super.key,
    required this.receiverName,
    required this.receiverPhone,
    required this.amount,
  });

  @override
  State<BluetoothTransactionScreen> createState() => _BluetoothTransactionScreenState();
}

class _BluetoothTransactionScreenState extends State<BluetoothTransactionScreen> {
  
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;

  bool _waitingConfirmation = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() async {
    _devices.clear();
    setState(() {}); // Refresh UI

    // Start scanning
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Listen for scan results
    FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        if (!_devices.any((d) => d.id == r.device.id)) {
          setState(() => _devices.add(r.device));
        }
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    final services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          _writeCharacteristic = characteristic;
        }
        if (characteristic.properties.read) {
          _readCharacteristic = characteristic;
          await characteristic.setNotifyValue(true);
          characteristic.value.listen(_onDataReceived);
        }
      }
    }
    setState(() => _connectedDevice = device);
  }

  void _onDataReceived(List<int> data) async {
    final response = utf8.decode(data);
    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(response);
      if (jsonResponse['type'] == 'payment_confirm') {
        setState(() => _waitingConfirmation = false);
        if (jsonResponse['status'] == 'accepted') {
          await TransactionQueue.queue({
            'method': 'P2P-BT',
            'name': widget.receiverName,
            'phone': widget.receiverPhone,
            'amount': widget.amount,
            'timestamp': DateTime.now().toIso8601String(),
            'status': 'completed',
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment confirmed and recorded.')));
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment rejected by receiver.')));
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('Error decoding confirmation: $e');
    }
  }

  Future<void> _sendPaymentRequest() async {
    if (_writeCharacteristic == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not connected to device')));
      return;
    }

    setState(() => _waitingConfirmation = true);

    final request = {
      'type': 'payment_request',
      'from': 'SenderName', // You can replace with real sender name from user profile
      'phone': 'SenderPhone', // Replace with sender phone too
      'amount': widget.amount,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final data = utf8.encode(jsonEncode(request));
    await _writeCharacteristic!.write(Uint8List.fromList(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Payment via Bluetooth')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Select device to connect:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  return ListTile(
                    title: Text(device.name.isNotEmpty ? device.name : device.id.toString()),
                    subtitle: Text(device.id.toString()),
                    onTap: () async {
                      await _connectToDevice(device);
                    },
                  );
                },
              ),
            ),
            if (_connectedDevice != null)
              ElevatedButton(
                onPressed: _waitingConfirmation ? null : _sendPaymentRequest,
                child: _waitingConfirmation
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Payment Request'),
              )
          ],
        ),
      ),
    );
  }
}
