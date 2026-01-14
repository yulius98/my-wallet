import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 3)
class Transaction {
  Transaction({
    required this.email,
    required this.date,
    required this.category,
    required this.item,
    required this.amount,
  });

  @HiveField(0)
  String email;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String category;

  @HiveField(3)
  String item;

  @HiveField(4)
  double amount;
}
