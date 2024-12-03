import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/pie_chart_widget.dart';
import 'package:expense_tracker/widgets/transaction_card.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _incomes = [];

  // Add dummy data for now
  @override
  void initState() {
    super.initState();
    _expenses = [
      {'title': 'Lunch', 'amount': 5000.0, 'date': DateTime.now()},
      {'title': 'Shopping', 'amount': 12000.0, 'date': DateTime.now()},
    ];
    _incomes = [
      {'title': 'Salary', 'amount': 30000.0, 'date': DateTime.now()},
      {'title': 'Freelancing', 'amount': 10000.0, 'date': DateTime.now()},
    ];
  }

  double _calculateTotal(List<Map<String, dynamic>> transactions) {
    return transactions.fold(
        0.0, (sum, transaction) => sum + (transaction['amount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _calculateTotal(_incomes);
    final totalExpenses = _calculateTotal(_expenses);
    final netBalance = totalIncome - totalExpenses;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            PieChartWidget(
              income: totalIncome,
              expenses: totalExpenses,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Net Balance: ${netBalance >= 0 ? 'Gain' : 'Loss'} of ${netBalance.abs().toStringAsFixed(2)} FCFA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: netBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  TransactionCard(
                    title: 'Recent Expenses',
                    transactions: _expenses,
                  ),
                  TransactionCard(
                    title: 'Recent sales',
                    transactions: _incomes,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
