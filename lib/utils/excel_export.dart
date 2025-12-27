import 'dart:io';
import 'package:excel/excel.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/expense_model.dart';

class ExcelExport {
  static Future<void> exportAllData() async {
    final box = Hive.box<ExpenseModel>('expenseBox');
    if (box.isEmpty) return;

    final excel = Excel.createExcel();
    final sheet = excel['All Expenses'];

    // ================= HEADER =================
    final headers = ['Date', 'Month', 'Title', 'Type', 'Amount'];
    for (int col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cell.value = headers[col] as dynamic;
    }

    // ================= SORT DATA =================
    final allData = box.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // ================= DATA =================
    int rowIndex = 1;
    for (final e in allData) {
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
              )
              .value =
          DateFormat('dd-MM-yyyy').format(e.date) as dynamic;
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
              )
              .value =
          DateFormat('MMMM yyyy').format(e.date) as dynamic;
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
              )
              .value =
          e.title as dynamic;
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
              )
              .value =
          e.type.toUpperCase() as dynamic;
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
              )
              .value =
          e.amount as dynamic;
      rowIndex++;
    }

    // ================= SAVE FILE =================
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'Office_Expense_Full_Data_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(excel.encode()!);

    // ================= OPEN FILE =================
    await OpenFile.open(file.path);
  }
}
