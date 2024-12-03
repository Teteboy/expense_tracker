import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  final String title;
  final double amount;

  const ExpenseCard({required this.title, required this.amount, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text('$amount FCFA'),
        leading: const Icon(Icons.money),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
