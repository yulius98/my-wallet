import 'package:hive/hive.dart';

part 'monthly_income.g.dart';

@HiveType(typeId: 2)
class MonthlyIncome {
  MonthlyIncome({
    required this.email,
    required this.date,
    required this.income,
  });

  @HiveField(0)
  String email;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double income;
}
