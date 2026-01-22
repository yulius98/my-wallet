import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_wallet/data/models/allocation_post.dart';
import 'package:my_wallet/data/models/monthly_income.dart';
import 'package:my_wallet/data/models/transaction.dart';
import 'package:my_wallet/data/models/initial_allocation.dart';

late Box<AllocationPost> boxAllocationPosts;
late Box<MonthlyIncome> boxMonthlyIncomes;
late Box<Transaction> boxTransactions;
late Box<InitialAllocation> boxInitialAllocations;

Future<void> initHiveBoxes() async {
  debugPrint('🔧 Starting Hive initialization...');

  await Hive.initFlutter();
  debugPrint('✅ Hive.initFlutter() completed');

  Hive.registerAdapter(MonthlyIncomeAdapter());
  Hive.registerAdapter(AllocationPostAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(InitialAllocationAdapter());
  debugPrint('✅ Adapters registered');

  // Open AllocationPostBox with error handling
  try {
    boxAllocationPosts = await Hive.openBox<AllocationPost>(
      'AllocationPostBox',
      compactionStrategy: (entries, deletedEntries) => deletedEntries > 20,
    );
    debugPrint(
      '✅ AllocationPostBox opened (${boxAllocationPosts.length} items)',
    );
  } catch (e) {
    debugPrint('❌ Error opening AllocationPostBox: $e');
    debugPrint('🔄 Deleting corrupt AllocationPostBox...');
    await Hive.deleteBoxFromDisk('AllocationPostBox');
    boxAllocationPosts = await Hive.openBox<AllocationPost>(
      'AllocationPostBox',
      compactionStrategy: (entries, deletedEntries) => deletedEntries > 20,
    );
    debugPrint('✅ AllocationPostBox recreated');
  }

  // Open MonthlyIncomeBox with error handling
  try {
    boxMonthlyIncomes = await Hive.openBox<MonthlyIncome>(
      'MonthlyIncomeBox',
      compactionStrategy: (entries, deletedEntries) => deletedEntries > 20,
    );
    debugPrint('✅ MonthlyIncomeBox opened (${boxMonthlyIncomes.length} items)');
  } catch (e) {
    debugPrint('❌ Error opening MonthlyIncomeBox: $e');
    debugPrint('🔄 Deleting corrupt MonthlyIncomeBox...');
    await Hive.deleteBoxFromDisk('MonthlyIncomeBox');
    boxMonthlyIncomes = await Hive.openBox<MonthlyIncome>(
      'MonthlyIncomeBox',
      compactionStrategy: (entries, deletedEntries) => deletedEntries > 20,
    );
    debugPrint('✅ MonthlyIncomeBox recreated');
  }

  // Open TransactionBox with error handling
  try {
    boxTransactions = await Hive.openBox<Transaction>(
      'TransactionBox',
      compactionStrategy: (entries, deletedEntries) => deletedEntries > 20,
    );
    debugPrint('✅ TransactionBox opened (${boxTransactions.length} items)');
  } catch (e) {
    debugPrint('❌ Error opening TransactionBox: $e');
    debugPrint('🔄 Deleting corrupt TransactionBox...');
    await Hive.deleteBoxFromDisk('TransactionBox');
    boxTransactions = await Hive.openBox<Transaction>(
      'TransactionBox',
      compactionStrategy: (entries, deletedEntries) => deletedEntries > 20,
    );
    debugPrint('✅ TransactionBox recreated');
  }


  // Open InitialAllocation with error handling
  try {
    boxInitialAllocations = await Hive.openBox<InitialAllocation>(
      'InitialAllocation',
      compactionStrategy: (entries, deletedEntries) => deletedEntries > 20,
    );
    debugPrint(
      '✅ InitialAllocationBox opened (${boxInitialAllocations.length} items)',
    );
  } catch (e) {
    debugPrint('❌ Error opening InitialAllocationBox: $e');
    debugPrint('🔄 Deleting corrupt InitialAllocationBox...');
    await Hive.deleteBoxFromDisk('InitialAllocationBox');
    boxInitialAllocations = await Hive.openBox<InitialAllocation>(
      'InitialAllocationBox',
      compactionStrategy: (entries, deletedEntries) => deletedEntries > 20,
    );
    debugPrint('✅ InitialAllocationBox recreated');
  }

  debugPrint('🎉 All Hive boxes initialized successfully');
}
