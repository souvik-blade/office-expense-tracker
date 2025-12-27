import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/expense_model.dart';

class AddExpense extends StatefulWidget {
  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String type = 'expense';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text(
          "Add Transaction",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("Transaction Type"),
            const SizedBox(height: 10),
            _typeSelector(),
            const SizedBox(height: 24),

            _label("Title"),
            const SizedBox(height: 8),
            _inputField(
              controller: titleController,
              hint: "Tea, Rent, Salary...",
              icon: Icons.description_outlined,
            ),
            const SizedBox(height: 20),

            _label("Amount"),
            const SizedBox(height: 8),
            _inputField(
              controller: amountController,
              hint: "Enter amount",
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),

            _saveButton(),
          ],
        ),
      ),
    );
  }

  // ================= Widgets =================

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _typeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          _typeButton("Income", "income", Colors.green),
          _typeButton("Expense", "expense", Colors.red),
        ],
      ),
    );
  }

  Widget _typeButton(String text, String value, Color color) {
    final isSelected = type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => type = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                value == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                color: isSelected ? color : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          if (titleController.text.isEmpty || amountController.text.isEmpty) {
            return;
          }

          final box = Hive.box<ExpenseModel>('expenseBox');
          box.add(
            ExpenseModel(
              title: titleController.text,
              amount: double.parse(amountController.text),
              type: type,
              date: DateTime.now(),
            ),
          );
          Navigator.pop(context);
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: type == 'income'
                  ? [Colors.green, Colors.teal]
                  : [Colors.redAccent, Colors.orange],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Text(
              "Save Transaction",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 249, 249, 249),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
