import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  bool isIncome;

  @HiveField(4)
  DateTime date;

  ExpenseModel({
    this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  /// 👉 For Sqflite INSERT
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isIncome': isIncome ? 1 : 0,
      'date': date.toIso8601String(),
    };
  }

  /// 👉 From Sqflite READ
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      isIncome: map['isIncome'] == 1,
      date: DateTime.parse(map['date']),
    );
  }
}
