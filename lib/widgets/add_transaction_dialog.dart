import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/expense_model.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final title = TextEditingController();
  final amount = TextEditingController();
  bool isIncome = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Transaction"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: title,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: amount,
            decoration: const InputDecoration(labelText: "Amount"),
            keyboardType: TextInputType.number,
          ),
          SwitchListTile(
            title: Text(isIncome ? "Income" : "Expense"),
            value: isIncome,
            onChanged: (v) => setState(() => isIncome = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            await DBHelper.instance.insertExpense(
              ExpenseModel(
                title: title.text,
                amount: double.parse(amount.text),
                isIncome: isIncome,
                date: DateTime.now(),
              ),
            );
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
