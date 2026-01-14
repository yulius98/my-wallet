import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_wallet/data/models/allocation_post.dart';
import 'package:my_wallet/data/models/monthly_income.dart';
import 'package:my_wallet/data/models/transaction.dart';

late Box<AllocationPost> boxAllocationPosts;
late Box<MonthlyIncome> boxMonthlyIncomes;
late Box<Transaction> boxTransactions;

Future<void> initHiveBoxes() async {
  await Hive.initFlutter();
  Hive.registerAdapter(MonthlyIncomeAdapter());
  Hive.registerAdapter(AllocationPostAdapter());
  Hive.registerAdapter(TransactionAdapter());
  boxAllocationPosts = await Hive.openBox<AllocationPost>('AllocationPostBox');
  boxMonthlyIncomes = await Hive.openBox<MonthlyIncome>('MonthlyIncomeBox');
  boxTransactions = await Hive.openBox<Transaction>('TransactionBox');
}
