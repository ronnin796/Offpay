import 'package:flutter/material.dart';
import '../services/transactions_queue.dart';

class PaymentFormScreen extends StatefulWidget {
  final String name;
  final String phone;

  const PaymentFormScreen({super.key, required this.name, required this.phone});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final transaction = {
        'method': 'QR',
        'name': widget.name,
        'phone': widget.phone,
        'amount': double.parse(_amountController.text),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await TransactionQueue.queue(transaction);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Transaction Queued'),
          content: Text('Payment to ${widget.name} queued successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Payment Amount')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: widget.name,
                decoration: const InputDecoration(labelText: 'Receiver Name'),
                enabled: false,
              ),
              TextFormField(
                initialValue: widget.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                enabled: false,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Queue Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
