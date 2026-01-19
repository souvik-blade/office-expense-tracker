import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class ExcelImport {
  static Future<void> importExpensesFromExcel() async {
    // 1️⃣ Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final bytes = await file.readAsBytes();

    final excel = Excel.decodeBytes(bytes);

    if (!excel.tables.containsKey('All Expenses')) {
      throw Exception("Invalid Excel format");
    }

    final sheet = excel.tables['All Expenses']!;
    final box = Hive.box<ExpenseModel>('expenseBox');

    // 2️⃣ Skip header row
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      if (row.length < 5) continue;

      try {
        final date = DateFormat('dd-MM-yyyy')
            .parse(row[0]!.value.toString());

        final title = row[2]!.value.toString();
        final type = row[3]!.value.toString().toUpperCase();
        final amount =
            double.parse(row[4]!.value.toString());

        box.add(
          ExpenseModel(
            title: title,
            amount: amount,
            isIncome: type == 'INCOME',
            date: date,
          ),
        );
      } catch (_) {
        // Skip malformed rows silently
        continue;
      }
    }
  }
}
