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
  const TransactionScreen({super.key, this.initialIndex = 1});

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

  List<String> _getCategories() {
    final user = AuthService.currentUser;
    if (user == null) {
      debugPrint('DEBUG: User is null');
      return [];
    }

    final userEmail = user.email ?? '';
    final selectedMonth = _selectedDate?.month;
    final selectedYear = _selectedDate?.year;

    debugPrint('DEBUG: Selected date: $_selectedDate');
    debugPrint('DEBUG: Looking for month: $selectedMonth, year: $selectedYear');
    debugPrint('DEBUG: User email: $userEmail');
    debugPrint(
      'DEBUG: Total allocation keys: ${boxAllocationPosts.keys.length}',
    );
    
    final categories = <String>{};

    for (var key in boxAllocationPosts.keys) {
      final keyStr = key.toString();
      debugPrint('DEBUG: Checking key: $keyStr');

      // Key format: key_{category}_{email}_{YYYYMM}
      if (keyStr.contains(userEmail)) {
        // Extract YYYYMM from end of key
        final parts = keyStr.split('_');
        if (parts.length >= 2) {
          final yyyymm = parts.last; // e.g., "202601"
          debugPrint('DEBUG: Extracted YYYYMM: $yyyymm');

          if (yyyymm.length == 6) {
            final keyYear = int.tryParse(yyyymm.substring(0, 4));
            final keyMonth = int.tryParse(yyyymm.substring(4, 6));

            debugPrint(
              'DEBUG: Parsed - keyYear: $keyYear, keyMonth: $keyMonth',
            );

            if (keyYear == selectedYear && keyMonth == selectedMonth) {
              final allocation = boxAllocationPosts.get(key);
              if (allocation != null) {
                debugPrint(
                  'DEBUG: Match found! Adding category: ${allocation.category}',
                );
                categories.add(allocation.category);
              }
            }
          }
        }
      }
    }
    
    debugPrint('DEBUG: Final categories: $categories');
    return categories.toList();
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

  void _updateAmountByCategory(String? category) {
    if (category == null) {
      _availableAmountController.clear();
      return;
    }

    final amount = _getAmountByCategory(category);
    if (amount != null) {
      _availableAmountController.text = NumberFormat(
        '#,##0.00',
        'en_US',
      ).format(amount);
    } else {
      _availableAmountController.clear();
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
        _selectedCategory = null;
        _availableAmountController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Transaksi",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
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
                    "Tambahkan Transaksi",
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
        borderRadius: BorderRadius.circular(14),
        color: AppTheme.cardBackground,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),
            const Text(
              "Kategori :",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final categories = _getCategories();
                final hasCategories = categories.isNotEmpty;
                final isEnabled = _selectedDate != null && hasCategories;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: _selectedDate == null
                            ? "Silakan pilih tanggal terlebih dahulu."
                            : (hasCategories
                                  ? "Pilih kategori"
                                  : "Tidak ada kategori yang tersedia untuk tanggal ini."),
                        helperText: _selectedDate == null
                            ? "Pilih tanggal transaksi untuk melihat kategori yang tersedia."
                            : (!hasCategories
                                  ? "Tidak ditemukan alokasi untuk ${DateFormat('MMMM yyyy').format(_selectedDate!)}. Silakan buat alokasi terlebih dahulu."
                                  : "Tersedia: ${categories.join(', ')}"),
                        helperStyle: TextStyle(
                          color: !hasCategories ? Colors.red : Colors.green,
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: isEnabled
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: isEnabled
                          ? categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList()
                          : null,
                      onChanged: isEnabled
                          ? (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                                _updateAmountByCategory(newValue);
                              });
                            }
                          : null,
                    ),
                  ],
                );
              },
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
                hintText: "Masukkan jumlah",
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
        borderRadius: BorderRadius.circular(14),
        color: AppTheme.cardBackground,
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
                const Text("Transaksi", style: TextStyle(fontSize: 13)),
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
                const Text("Jumlah", style: TextStyle(fontSize: 13)),
                const SizedBox(width: 40),
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
