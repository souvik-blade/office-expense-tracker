import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:office_expense_tracker/app_theme.dart';
import '../models/expense_model.dart';
import 'add_expense_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = Hive.box<ExpenseModel>('expenseBox');

  DateTime selectedMonth = DateTime.now();

  // ================= MONTH FILTER =================
  List<ExpenseModel> get monthlyData {
    return box.values.where((e) {
      return e.date.month == selectedMonth.month &&
          e.date.year == selectedMonth.year;
    }).toList();
  }

  // ================= TOTALS =================
  double totalIncome() {
    return monthlyData
        .where((e) => e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double totalExpense() {
    return monthlyData
        .where((e) => !e.isIncome)
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
        backgroundColor: AppTheme.indigoAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add"),
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
      expandedHeight: 140, // 👈 give it enough room
      backgroundColor: AppTheme.indigoAccent,

      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        expandedTitleScale: 1.2,
        title: Row(
          children: [
            IconButton(
              onPressed: () => changeMonth(-1),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            Text(
              DateFormat('MMMM yyyy').format(selectedMonth),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            IconButton(
              onPressed: () => changeMonth(1),
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.bar_chart, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReportScreen()),
              ),
            ),
          ],
        ),
        background: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: const Text(
              "Vision Expense Tracker",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     const SizedBox(height: 24),
            //     const Text(
            //       "Vision Expense Tracker",
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 22,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),

            //     const SizedBox(height: 12),
            //     Row(
            //       children: [
            //         IconButton(
            //           onPressed: () => changeMonth(-1),
            //           icon: const Icon(
            //             Icons.arrow_back_ios,
            //             color: Colors.white,
            //           ),
            //         ),
            //         Text(
            //           DateFormat('MMMM yyyy').format(selectedMonth),
            //           style: const TextStyle(color: Colors.white, fontSize: 16),
            //         ),
            //         IconButton(
            //           onPressed: () => changeMonth(1),
            //           icon: const Icon(
            //             Icons.arrow_forward_ios,
            //             color: Colors.white,
            //           ),
            //         ),
            //         const Spacer(),
            //         IconButton(
            //           icon: const Icon(Icons.bar_chart, color: Colors.white),
            //           onPressed: () => Navigator.push(
            //             context,
            //             MaterialPageRoute(builder: (_) => ReportScreen()),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
          ),
        ),
      ),
    );
  }

  // ================= SUMMARY =================
  SliverToBoxAdapter _buildSummaryCards() {
    final income = totalIncome();
    final expense = totalExpense();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _summaryCard("Income", income, Colors.green),
            const SizedBox(width: 12),
            _summaryCard("Expense", expense, Colors.red),
            const SizedBox(width: 12),
            _summaryCard("Balance", income - expense, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
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
            const SizedBox(height: 8),
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
        final isIncome = item.isIncome;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isIncome
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(DateFormat('dd MMM yyyy').format(item.date)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "₹ ${item.amount}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
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
