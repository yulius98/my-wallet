import 'package:hive/hive.dart';

part 'initial_allocation.g.dart';

@HiveType(typeId: 4)
class InitialAllocation {
  InitialAllocation({
    required this.email,
    required this.category,
    required this.amount,
    required this.date,
  });

  @HiveField(0)
  String category;

  @HiveField(1)
  String email;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;
}
