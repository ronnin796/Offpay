import 'dart:math';

final List<Map<String, dynamic>> demoTransactions = [
  {
    'method': 'P2P-BT',
    'sender': {'name': 'Alice', 'phone': '1111111111'},
    'receiver': {'name': 'Bob', 'phone': '2222222222'},
    'amount': 100.0,
    'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    'status': 'completed'
  },
  {
    'method': 'QR',
    'sender': {'name': 'Charlie', 'phone': '3333333333'},
    'receiver': {'name': 'Diana', 'phone': '4444444444'},
    'amount': 250.0,
    'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    'status': 'completed'
  },
  {
    'method': 'P2P-BT',
    'sender': {'name': 'Eve', 'phone': '5555555555'},
    'receiver': {'name': 'Frank', 'phone': '6666666666'},
    'amount': 75.5,
    'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    'status': 'completed'
  },
  {
    'method': 'QR',
    'sender': {'name': 'Grace', 'phone': '7777777777'},
    'receiver': {'name': 'Heidi', 'phone': '8888888888'},
    'amount': 320.0,
    'timestamp': DateTime.now().subtract(const Duration(minutes: 90)).toIso8601String(),
    'status': 'completed'
  },
];

final _usedIndexes = <int>{};

Map<String, dynamic> getRandomDemoTransaction() {
  if (_usedIndexes.length == demoTransactions.length) {
    _usedIndexes.clear(); // Reset if all used
  }
  int idx;
  do {
    idx = Random().nextInt(demoTransactions.length);
  } while (_usedIndexes.contains(idx));
  _usedIndexes.add(idx);
  return Map<String, dynamic>.from(demoTransactions[idx]);
}