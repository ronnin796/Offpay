// receiver_bluetooth_server_screen.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/transactions_queue.dart';

class ReceiverBluetoothServerScreen extends StatefulWidget {
  const ReceiverBluetoothServerScreen({super.key});

  @override
  State<ReceiverBluetoothServerScreen> createState() => _ReceiverBluetoothServerScreenState();
}

class _ReceiverBluetoothServerScreenState extends State<ReceiverBluetoothServerScreen> {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus();
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;

  @override
  void initState() {
    super.initState();
    _startAdvertisingAndListening();
  }

  // This is a stub — flutter_blue_plus currently has limited peripheral support on Android/iOS
  // So we simulate by scanning and waiting for connection (usually receiver waits passively)
  void _startAdvertisingAndListening() {
    // Normally on receiver you would advertise your device to allow sender to connect.
    // Since flutter_blue_plus has limited peripheral mode support, we skip actual advertising here.

    // You could prompt user to make their device discoverable manually.
  }

  Future<void> _onDeviceConnected(BluetoothDevice device) async {
    setState(() => _connectedDevice = device);

    final services = await device.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.read) {
          _readCharacteristic = characteristic;
          await characteristic.setNotifyValue(true);
          characteristic.value.listen(_onDataReceived);
        }
        if (characteristic.properties.write) {
          _writeCharacteristic = characteristic;
        }
      }
    }
  }

  void _onDataReceived(List<int> data) async {
    try {
      final message = utf8.decode(data);
      final Map<String, dynamic> request = jsonDecode(message);

      if (request['type'] == 'payment_request') {
        final confirmed = await _showConfirmationDialog(request);
        if (confirmed) {
          await TransactionQueue.queue({
            'method': 'P2P-BT',
            'name': request['from'],
            'phone': request['phone'],
            'amount': request['amount'],
            'timestamp': DateTime.now().toIso8601String(),
            'status': 'completed',
          });

          // Send confirmation back
          final response = jsonEncode({'type': 'payment_confirm', 'status': 'accepted'});
          await _writeCharacteristic?.write(Uint8List.fromList(utf8.encode(response)));

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment accepted and recorded')));
        } else {
          final response = jsonEncode({'type': 'payment_confirm', 'status': 'rejected'});
          await _writeCharacteristic?.write(Uint8List.fromList(utf8.encode(response)));
        }
      }
    } catch (e) {
      debugPrint('Error parsing Bluetooth data: $e');
    }
  }

  Future<bool> _showConfirmationDialog(Map<String, dynamic> request) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Confirmation'),
            content: Text(
              '${request['from']} wants to pay you ₹${request['amount']}.\nAccept?',
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Reject')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Accept')),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receiver Bluetooth Server')),
      body: Center(
        child: _connectedDevice == null
            ? const Text('Waiting for sender to connect...')
            : Text('Connected to: ${_connectedDevice!.name}'),
      ),
    );
  }
}
