import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:excel/excel.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;
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
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
          .value = TextCellValue(headers[col]);
    }

    // ================= SORT DATA =================
    final allData = box.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // ================= DATA =================
    int rowIndex = 1;
    for (final e in allData) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(DateFormat('dd-MM-yyyy').format(e.date));

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(DateFormat('MMMM yyyy').format(e.date));

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(e.title);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(
        e.isIncome ? 'INCOME' : 'EXPENSE',
      );

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = DoubleCellValue(e.amount);

      rowIndex++;
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    final fileName = 'Office_Expense_Full_Data_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';

    if (kIsWeb) {
      // ================= WEB DOWNLOAD =================
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // ================= MOBILE/DESKTOP SAVE =================
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // ================= OPEN FILE =================
      await OpenFile.open(file.path);
    }
  }
}
