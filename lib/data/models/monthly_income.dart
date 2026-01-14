import 'package:hive/hive.dart';

part 'monthly_income.g.dart';

@HiveType(typeId: 2)
class MonthlyIncome {
  MonthlyIncome({
    required this.income,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  @HiveField(0)
  double income;

  @HiveField(1)
  DateTime date;
}
