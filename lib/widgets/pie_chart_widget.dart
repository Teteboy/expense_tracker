import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChartWidget extends StatelessWidget {
  final double income;
  final double expenses;

  const PieChartWidget({required this.income, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      series: <CircularSeries>[
        PieSeries<Map<String, dynamic>, String>(
          dataSource: [
            {'category': 'Income', 'amount': income},
            {'category': 'Expenses', 'amount': expenses},
          ],
          xValueMapper: (data, _) => data['category'],
          yValueMapper: (data, _) => data['amount'],
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
}
