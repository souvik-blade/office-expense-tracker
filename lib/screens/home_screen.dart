import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import 'add_expense_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = Hive.box<ExpenseModel>('expenseBox');

  DateTime selectedMonth = DateTime.now();

  List<ExpenseModel> get monthlyData {
    return box.values.where((e) {
      if (e.date == null) return false;

      return e.date.month == selectedMonth.month &&
          e.date.year == selectedMonth.year;
    }).toList();
  }

  double total(String type) {
    return monthlyData
        .where((e) => e.type == type)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  void changeMonth(int value) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddExpense()),
        ),
        icon: Icon(Icons.add),
        label: Text("Add"),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<ExpenseModel> box, _) {
          return CustomScrollView(
            slivers: [
              _buildHeader(),
              _buildSummaryCards(),
              _buildTransactionList(),
            ],
          );
        },
      ),
    );
  }

  // ================= HEADER =================
  SliverAppBar _buildHeader() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 160,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 50, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Office Expense Tracker",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: () => changeMonth(-1),
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(selectedMonth),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () => changeMonth(1),
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.bar_chart, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReportScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SUMMARY =================
  SliverToBoxAdapter _buildSummaryCards() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            _summaryCard("Income", total('income'), Colors.green),
            SizedBox(width: 12),
            _summaryCard("Expense", total('expense'), Colors.red),
            SizedBox(width: 12),
            _summaryCard(
              "Balance",
              total('income') - total('expense'),
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "₹ ${amount.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LIST =================
  SliverList _buildTransactionList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, i) {
        final item = monthlyData[i];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item.type == 'income'
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                child: Icon(
                  item.type == 'income'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: item.type == 'income' ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                item.title,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(DateFormat('dd MMM yyyy').format(item.date)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "₹ ${item.amount}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item.type == 'income' ? Colors.green : Colors.red,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => item.delete(),
                  ),
                ],
              ),
            ),
          ),
        );
      }, childCount: monthlyData.length),
    );
  }
}
