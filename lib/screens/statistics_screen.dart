import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Importing Syncfusion charts library

class StatisticsScreen extends StatelessWidget {
  // Dummy data for the bar chart (you can replace with dynamic data)
  final List<ExpenseData> incomeData = [
    ExpenseData('Sales', 30000.0),
  ];

  final List<ExpenseData> expenseData = [
    ExpenseData('Food', 10000.0),
    ExpenseData('Transport', 5000.0),
    ExpenseData('Shopping', 8000.0),
    ExpenseData('Others', 2000.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistics"),
      ),
      body: Column(
        children: [
          // Syncfusion Bar Chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(), // Defining the X-axis as category-based
                series: <CartesianSeries>[
                  // Expense Series
                  ColumnSeries<ExpenseData, String>(
                    dataSource: expenseData,
                    xValueMapper: (ExpenseData data, _) => data.category,
                    yValueMapper: (ExpenseData data, _) => data.amount,
                    name: 'Expenses',
                    color: Colors.red,
                  ),
                  // Income Series
                  ColumnSeries<ExpenseData, String>(
                    dataSource: incomeData,
                    xValueMapper: (ExpenseData data, _) => data.category,
                    yValueMapper: (ExpenseData data, _) => data.amount,
                    name: 'Income',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          // Descriptions under the chart
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Income: \XAF45,000',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Expenses: \XAF25,000',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Net Balance: \XAF20,000',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data model for the chart
class ExpenseData {
  final String category;
  final double amount;

  ExpenseData(this.category, this.amount);
}
