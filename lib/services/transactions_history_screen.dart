import 'package:flutter/material.dart';
import '../services/transactions_queue.dart';

class TransactionsHistoryScreen extends StatefulWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  State<TransactionsHistoryScreen> createState() => _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = TransactionQueue.getQueued();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Transactions')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _transactions,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final txs = snapshot.data!;
          if (txs.isEmpty) {
            return const Center(child: Text('No offline transactions yet.'));
          }
          return ListView.separated(
            itemCount: txs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final tx = txs[i];
              return ListTile(
                leading: const Icon(Icons.qr_code),
                title: Text('Method: ${tx['method']}'),
                subtitle: Text('Amount: ${tx['amount']}\nTime: ${tx['timestamp']}'),
                isThreeLine: true,
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              );
            },
          );
        },
      ),
    );
  }
}