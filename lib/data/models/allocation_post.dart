import 'package:hive/hive.dart';

part 'allocation_post.g.dart';

@HiveType(typeId: 1)
class AllocationPost {
  AllocationPost({
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
