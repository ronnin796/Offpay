import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactions = TransactionQueue.getQueued();
  }

  Future<void> _syncTransaction(int index, Map<String, dynamic> tx) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No internet connection')));
      return;
    }
    // Prepare only the required fields for backend
    final txForBackend = {
      'method': tx['method'],
      'sender': tx['sender'],
      'receiver': tx['receiver'],
      'amount': tx['amount'],
      'timestamp': tx['timestamp'],
    };
    final url = Uri.parse('http://10.200.10.156:8000/api/sync/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '[${jsonEncode(txForBackend)}]', // Django expects a list
      );
      if (response.statusCode == 201) {
        tx['synced'] = true;
        await TransactionQueue.update(index, tx);
        setState(() => _loadTransactions());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Synced with server')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync error: $e')));
    }
  }

  Future<void> _syncAll(List<Map<String, dynamic>> txs) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No internet connection')));
      return;
    }
    for (int i = 0; i < txs.length; i++) {
      final tx = txs[i];
      if (!(tx['synced'] ?? false)) {
        await _syncTransaction(i, tx);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Transactions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync All',
            onPressed: () async {
              final txs = await _transactions;
              await _syncAll(txs);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _transactions,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final txs = snapshot.data!..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
          if (txs.isEmpty) {
            return const Center(child: Text('No offline transactions yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: txs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final tx = txs[i];
              final dt = DateFormat.yMd().add_jm().format(DateTime.parse(tx['timestamp']));
              final synced = tx['synced'] == true;
              return ListTile(
                leading: Icon(Icons.qr_code_2_rounded, color: synced ? Colors.green : Colors.orangeAccent),
                title: Text('To: ${tx['receiver']?['name'] ?? '-'} (${tx['receiver']?['phone'] ?? '-'})'),
                subtitle: Text(
                  'From: ${tx['sender']?['name'] ?? '-'} (${tx['sender']?['phone'] ?? '-'})\n'
                  'Amount: ₹${tx['amount'] ?? '-'}\n'
                  'Time: $dt',
                ),
                isThreeLine: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      synced ? Icons.check_circle : Icons.sync_problem,
                      color: synced ? Colors.green : Colors.red,
                    ),
                    if (!synced)
                      TextButton(
                        onPressed: () => _syncTransaction(i, tx),
                        child: const Text('Retry'),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}