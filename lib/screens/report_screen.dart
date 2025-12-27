import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/expense_model.dart';
import '../utils/excel_export.dart';

class ReportScreen extends StatelessWidget {
  ReportScreen({super.key});

  final box = Hive.box<ExpenseModel>('expenseBox');

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final monthlyData = box.values.where(
      (e) => e.date.year == now.year && e.date.month == now.month,
    );

    final income = monthlyData
        .where((e) => e.type == 'income')
        .fold<double>(0, (s, e) => s + e.amount);

    final expense = monthlyData
        .where((e) => e.type == 'expense')
        .fold<double>(0, (s, e) => s + e.amount);

    final total = income + expense;

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      body: CustomScrollView(
        slivers: [
          _header(context),
          _summary(income, expense),
          _chart(income, expense, total),
        ],
      ),
    );
  }

  // ================= HEADER =================
  SliverAppBar _header(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 160,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.download, color: Colors.white),
          tooltip: "Export All Data",
          onPressed: () {
            ExcelExport.exportAllData();
          },
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Monthly Report",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SUMMARY =================
  SliverToBoxAdapter _summary(double income, double expense) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _summaryCard("Income", income, Colors.green),
            const SizedBox(width: 12),
            _summaryCard("Expense", expense, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "₹ ${amount.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CHART =================
  SliverToBoxAdapter _chart(double income, double expense, double total) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                "Income vs Expense",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 60,
                    sectionsSpace: 4,
                    sections: [
                      _section(income, total, Colors.green),
                      _section(expense, total, Colors.red),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PieChartSectionData _section(double value, double total, Color color) {
    final percent = total == 0 ? 0 : ((value / total) * 100).toStringAsFixed(1);

    return PieChartSectionData(
      value: value,
      color: color,
      radius: 40,
      title: "$percent%",
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
