import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> transactions;

  TransactionCard({required this.title, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ExpansionTile(
        title: Text(title),
        children: transactions
            .map((transaction) => ListTile(
                  title: Text(transaction['title']),
                  subtitle:
                      Text('${transaction['amount'].toStringAsFixed(2)} FCFA'),
                  trailing: Text(
                      '${transaction['date'].day}-${transaction['date'].month}-${transaction['date'].year}'),
                ))
            .toList(),
      ),
    );
  }
}
