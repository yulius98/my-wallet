import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:my_wallet/core/theme/app_theme.dart';
import 'package:my_wallet/presentation/widgets/common/custom_bottom_nav_bar.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/services/auth_service.dart';
import 'package:my_wallet/data/local/hive_boxes.dart';
import 'package:my_wallet/data/models/transaction.dart' as transaction_model;

class TransactionScreen extends StatefulWidget {
  final int initialIndex;
  final String? selectedCategory;
  const TransactionScreen({
    super.key,
    this.initialIndex = 1,
    this.selectedCategory,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late int _currentIndex;
  DateTime? _selectedDate;
  String? _selectedCategory;

  final TextEditingController _availableAmountController =
      TextEditingController();

  // List untuk menyimpan multiple transactions
  final List<Map<String, TextEditingController>> _transactionList = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Set kategori dari parameter jika ada
    if (widget.selectedCategory != null) {
      _selectedCategory = widget.selectedCategory;
      // Auto-set tanggal ke bulan saat ini ketika kategori dipilih dari home screen
      _selectedDate = DateTime.now();
      
      // Auto-fill available amount berdasarkan kategori yang dipilih
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateAvailableAmount();
      });
    }
  }
  
  void _updateAvailableAmount() {
    if (_selectedCategory != null) {
      final amount = _getAmountByCategory(_selectedCategory!);
      if (amount != null) {
        setState(() {
          _availableAmountController.text = 
              NumberFormat('#,##0', 'en_US').format(amount);
        });
      }
    }
  }

  @override
  void dispose() {
    _availableAmountController.dispose();
    // Dispose all transaction controllers
    for (var transaction in _transactionList) {
      transaction['item']?.dispose();
      transaction['amount']?.dispose();
    }
    super.dispose();
  }

  void _addTransaction() {
    setState(() {
      _transactionList.add({
        'item': TextEditingController(),
        'amount': TextEditingController(),
      });
    });
  }

  void _removeTransaction(int index) {
    setState(() {
      _transactionList[index]['item']?.dispose();
      _transactionList[index]['amount']?.dispose();
      _transactionList.removeAt(index);
    });
  }

  Future<void> _saveTransaction() async {
    // Validasi
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal transaksi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_transactionList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tambahkan setidaknya satu item transaksi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = AuthService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengguna tidak terautentikasi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userEmail = user.email ?? '';

    // Validasi available amount
    final availableAmountText = _availableAmountController.text.trim();
    if (availableAmountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah yang tersedia diperlukan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final availableAmount = double.tryParse(
      availableAmountText.replaceAll(',', ''),
    );

    if (availableAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format jumlah yang tersedia tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Hitung total amount dari semua transaksi
      double totalTransactionAmount = 0;
      final List<Map<String, dynamic>> validatedTransactions = [];

      for (var controllers in _transactionList) {
        final itemText = controllers['item']!.text.trim();
        final amountText = controllers['amount']!.text.trim();

        if (itemText.isEmpty || amountText.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Silakan isi semua kolom transaksi.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Parse amount (remove comma separator)
        final amountValue = double.tryParse(amountText.replaceAll(',', ''));
        if (amountValue == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Format jumlah tidak valid'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        totalTransactionAmount += amountValue;
        validatedTransactions.add({'item': itemText, 'amount': amountValue});
      }

      // Cek apakah dana mencukupi
      final remainingAmount = availableAmount - totalTransactionAmount;

      if (remainingAmount < 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Saldo tidak mencukupi untuk transaksi. Kekurangan: ${NumberFormat('#,##0.00', 'en_US').format(remainingAmount.abs())}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Simpan setiap transaction item ke Hive
      for (var transactionData in validatedTransactions) {
        // Create transaction object
        final transaction = transaction_model.Transaction(
          email: userEmail,
          date: _selectedDate!,
          category: _selectedCategory!,
          item: transactionData['item'],
          amount: transactionData['amount'],
        );
  
        // Save to Hive with unique key
        final key = '${DateTime.now().millisecondsSinceEpoch}_$userEmail';
        await boxTransactions.put(key, transaction);
        // Add small delay to ensure unique keys
        await Future.delayed(const Duration(milliseconds: 1));
      }

      // Update allocation amount dengan sisa dana
      final selectedMonth = _selectedDate!.month;
      final selectedYear = _selectedDate!.year;

      for (var key in boxAllocationPosts.keys) {
        final keyStr = key.toString();

        // Key format: key_{category}_{email}_{YYYYMM}
        if (keyStr.contains(userEmail)) {
          // Extract YYYYMM from end of key
          final parts = keyStr.split('_');
          if (parts.length >= 2) {
            final yyyymm = parts.last;

            if (yyyymm.length == 6) {
              final keyYear = int.tryParse(yyyymm.substring(0, 4));
              final keyMonth = int.tryParse(yyyymm.substring(4, 6));

              if (keyYear == selectedYear && keyMonth == selectedMonth) {
                final allocation = boxAllocationPosts.get(key);
                if (allocation != null &&
                    allocation.category == _selectedCategory) {
                  allocation.amount = remainingAmount;
                  await boxAllocationPosts.put(key, allocation);
                  break;
                }
              }
            }
          }
        }
      }

      // Success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaksi berhasil disimpan! Sisa dana: ${NumberFormat('#,##0.00', 'en_US').format(remainingAmount)}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Clear form
      setState(() {
        _selectedDate = null;
        _selectedCategory = null;
        _availableAmountController.clear();

        // Dispose and clear transaction list
        for (var transaction in _transactionList) {
          transaction['item']?.dispose();
          transaction['amount']?.dispose();
        }
        _transactionList.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kesalahan saat menyimpan transaksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double? _getAmountByCategory(String category) {
    final user = AuthService.currentUser;
    if (user == null) return null;

    final userEmail = user.email ?? '';
    final selectedMonth = _selectedDate?.month;
    final selectedYear = _selectedDate?.year;

    for (var key in boxAllocationPosts.keys) {
      final keyStr = key.toString();

      // Key format: key_{category}_{email}_{YYYYMM}
      if (keyStr.contains(userEmail)) {
        // Extract YYYYMM from end of key
        final parts = keyStr.split('_');
        if (parts.length >= 2) {
          final yyyymm = parts.last;

          if (yyyymm.length == 6) {
            final keyYear = int.tryParse(yyyymm.substring(0, 4));
            final keyMonth = int.tryParse(yyyymm.substring(4, 6));

            if (keyYear == selectedYear && keyMonth == selectedMonth) {
              final allocation = boxAllocationPosts.get(key);
              if (allocation != null && allocation.category == category) {
                return allocation.amount;
              }
            }
          }
        }
      }
    }

    return null;
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    // Tanggal pertama bulan ini
    final firstDateOfMonth = DateTime(now.year, now.month, 1);
    // Tanggal terakhir bulan ini
    final lastDateOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDateOfMonth,
      lastDate: lastDateOfMonth,
      builder: (context, child) {
        return DatePickerTheme(
          data: DatePickerThemeData(
            backgroundColor: Colors.white,
            headerBackgroundColor: Colors.blue,
            headerForegroundColor: Colors.white,
            dayStyle: TextStyle(color: Colors.black),
            yearStyle: TextStyle(color: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Reset category dan amount ketika tanggal berubah
        //_selectedCategory = null;
        //_availableAmountController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.javaneseBrownGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.javaneseGold.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.javaneseGold.withValues(alpha: .5),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppTheme.javaneseGoldLight,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Transaksi",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.javaneseGoldLight,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        user: user,
        onTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.backgroundPath),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 17),
                _chooseCategory(),

                const SizedBox(height: 17),
                _action(),

                const SizedBox(height: 17),

                // Display all transaction items dynamically
                ..._transactionList.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, TextEditingController> controllers = entry.value;

                  return Column(
                    children: [
                      _buildTransactionItem(
                        index,
                        controllers['item']!,
                        controllers['amount']!,
                      ),
                      const SizedBox(height: 17),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _action() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _addTransaction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    "Tambah Transaksi",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: _saveTransaction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.save, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    "Simpan Transaksi",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _chooseCategory() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.javaneseBeige,
            AppTheme.javanesesCream,
            Colors.white.withValues(alpha: .95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.javaneseGold, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .4),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppTheme.javaneseGold.withValues(alpha: .2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],

      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Kategori :",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              width: double.infinity,
              child: Text(
                _selectedCategory ?? "Kategori belum dipilih",
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedCategory != null
                      ? Colors.black
                      : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Jumlah yang Tersedia :",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _availableAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                CurrencyInputFormatter(
                  thousandSeparator: ThousandSeparator.Comma,
                  mantissaLength: 2,
                ),
              ],
              decoration: InputDecoration(
                hintText: "Dana yang tersedia",
                filled: false,
                fillColor: Colors.white.withValues(alpha: 0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Tanggal Transaksi :",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? "Pilih Tanggal"
                          : DateFormat('dd-MM-yyyy').format(_selectedDate!),
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedDate == null
                            ? Colors.grey.shade600
                            : Colors.black,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
            
            
            
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    int index,
    TextEditingController itemController,
    TextEditingController amountController,
  ) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, AppTheme.javanesesCream.withValues(alpha: .5)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.javaneseGold.withValues(alpha: .3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.javaneseBrown.withValues(alpha: .1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Delete button
          Positioned(
            right: 5,
            top: 5,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20, color: Colors.red),
              onPressed: () => _removeTransaction(index),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 10,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text("Transaksi", style: TextStyle(fontSize: 13)),
                ),

                const SizedBox(width: 18),
                Expanded(
                  child: TextFormField(
                    controller: itemController,

                    decoration: InputDecoration(
                      hintText: "Masukkan transaksi",
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 65,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text("Jumlah", style: TextStyle(fontSize: 13)),
                ),

                const SizedBox(width: 18),
                Expanded(
                  child: TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      CurrencyInputFormatter(
                        thousandSeparator: ThousandSeparator.Comma,
                        mantissaLength: 2,
                      ),
                    ],
                    decoration: InputDecoration(
                      hintText: "Masukkan jumlah",
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
