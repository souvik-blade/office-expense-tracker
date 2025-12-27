import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class ExpenseChart extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const ExpenseChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    double income = expenses
        .where((e) => e.isIncome)
        .fold(0, (sum, e) => sum + e.amount);
    double expense = expenses
        .where((e) => !e.isIncome)
        .fold(0, (sum, e) => sum + e.amount);

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: income,
              color: Colors.green,
              title: "Income",
            ),
            PieChartSectionData(
              value: expense,
              color: Colors.red,
              title: "Expense",
            ),
          ],
        ),
      ),
    );
  }
}
