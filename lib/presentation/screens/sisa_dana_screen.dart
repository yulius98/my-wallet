import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/core/theme/app_theme.dart';
import 'package:my_wallet/presentation/screens/home_screen.dart';
import 'package:my_wallet/services/auth_service.dart';
import 'package:my_wallet/data/local/hive_boxes.dart';
import 'package:my_wallet/core/utils/currency_utils.dart';
import 'package:my_wallet/presentation/widgets/common/month_picker_bottom_sheet.dart';

class SisaDanaScreen extends StatefulWidget {
  const SisaDanaScreen({super.key});

  @override
  State<SisaDanaScreen> createState() => _SisaDanaScreenState();
}

class _SisaDanaScreenState extends State<SisaDanaScreen> {
  DateTime _selectedMonth = DateTime.now();

  final TextEditingController _monthlyIncomeController =
      TextEditingController();
  final TextEditingController _remainingFundsController =
      TextEditingController();
  final TextEditingController _housingutilitiesController =
      TextEditingController();
  final TextEditingController _foodTransportController =
      TextEditingController();
  final TextEditingController _healthInsuranceController =
      TextEditingController();
  final TextEditingController _otherRegularExpensesController =
      TextEditingController();
  final TextEditingController _emergencyFundController =
      TextEditingController();
  final TextEditingController _longTermInvestmentController =
      TextEditingController();
  final TextEditingController _installmentsOutsideMortgagesController =
      TextEditingController();
  final TextEditingController _creditCardInstalmentsController =
      TextEditingController();
  final TextEditingController _otherInstalmentsController =
      TextEditingController();
  final TextEditingController _healthFitnessController =
      TextEditingController();
  final TextEditingController _skillsDevelopmentEducationController =
      TextEditingController();
  final TextEditingController _entertainmentSelfRewardController =
      TextEditingController();

  String get formattedMonth {
    return DateFormat('MMMM yyyy').format(_selectedMonth);
  }

  // Fungsi untuk menghitung total transaksi berdasarkan bulan yang dipilih
  double _calculateTotalTransactions() {
    final user = AuthService.currentUser;
    if (user == null) return 0.0;

    String userEmail = user.email ?? 'unknown@email.com';
    double totalTransactions = 0.0;

    // Iterasi semua transaksi di box
    for (var transaction in boxTransactions.values) {
      // Filter transaksi berdasarkan email, bulan, dan tahun
      if (transaction.email == userEmail &&
          transaction.date.year == _selectedMonth.year &&
          transaction.date.month == _selectedMonth.month) {
        totalTransactions += transaction.amount;
      }
    }

    return totalTransactions;
  }

  // Fungsi untuk mengupdate remaining funds
  void _updateRemainingFunds() {
    final user = AuthService.currentUser;
    if (user == null) {
      _remainingFundsController.clear();
      return;
    }

    String userEmail = user.email ?? 'unknown@email.com';
    String monthYearKey =
        '${_selectedMonth.year}${_selectedMonth.month.toString().padLeft(2, '0')}';

    // Ambil monthly income
    final monthlyIncome = boxMonthlyIncomes.get(
      'key_income_${userEmail}_$monthYearKey',
    );

    if (monthlyIncome != null) {
      // Hitung total transaksi
      double totalTransactions = _calculateTotalTransactions();
      
      // Hitung sisa dana
      double remainingFunds = monthlyIncome.income - totalTransactions;
      
      // Update controller
      _remainingFundsController.text = CurrencyUtils.formatCurrency(
        remainingFunds,
      );
    } else {
      _remainingFundsController.clear();
    }
  }

  void _loadMonthlyIncome() {
    final user = AuthService.currentUser;
    String userEmail = user?.email ?? 'unknown@email.com';

    // Format bulan-tahun untuk key (contoh: 202601 untuk Januari 2026)
    String monthYearKey =
        '${_selectedMonth.year}${_selectedMonth.month.toString().padLeft(2, '0')}';

    // Load monthly income berdasarkan bulan yang dipilih
    final monthlyIncome = boxMonthlyIncomes.get(
      'key_income_${userEmail}_$monthYearKey',
    );
    

    if (monthlyIncome != null) {
      _monthlyIncomeController.text = CurrencyUtils.formatCurrency(
        monthlyIncome.income,
      );
    } else {
      _monthlyIncomeController.clear();
    }

    // Map untuk menyederhanakan loading allocation data
    final allocationMap = {
      //final allocationMap = {
      'housing': _housingutilitiesController,
      'food': _foodTransportController,
      'health': _healthInsuranceController,
      'otherexpense': _otherRegularExpensesController,
      'emergency': _emergencyFundController,
      'investement': _longTermInvestmentController,
      'installments': _installmentsOutsideMortgagesController,
      'creditcards': _creditCardInstalmentsController,
      'otherInstallments': _otherInstalmentsController,
      'healths': _healthFitnessController,
      'skilleducation': _skillsDevelopmentEducationController,
      'entertaiment': _entertainmentSelfRewardController,
    };

    // Load semua initialallocation data dalam satu loop berdasarkan bulan yang dipilih
    allocationMap.forEach((key, controller) {
      final allocation = boxAllocationPosts.get(
        'key_${key}_${userEmail}_$monthYearKey',
      );
      if (allocation != null) {
        controller.text = CurrencyUtils.formatCurrency(allocation.amount);
      } else {
        controller.clear();
      }
    });

    // Update remaining funds setelah load data
    _updateRemainingFunds();
  }

  

  void _openMonthPicker() async {
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MonthPickerBottomSheet(initialDate: _selectedMonth),
    );

    if (result != null) {
      setState(() {
        _selectedMonth = result;
        _loadMonthlyIncome(); // Load data untuk bulan yang dipilih
      });
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _loadMonthlyIncome(); // Load data untuk bulan sebelumnya
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _loadMonthlyIncome(); // Load data untuk bulan berikutnya
    });
  }

  @override
  void initState() {
    super.initState();
    // Load data saat screen pertama kali dibuka
    _loadMonthlyIncome();
  }

  @override
  void dispose() {
    _monthlyIncomeController.dispose();
    _remainingFundsController.dispose();
    _housingutilitiesController.dispose();
    _foodTransportController.dispose();
    _healthInsuranceController.dispose();
    _otherRegularExpensesController.dispose();
    _emergencyFundController.dispose();
    _longTermInvestmentController.dispose();
    _installmentsOutsideMortgagesController.dispose();
    _creditCardInstalmentsController.dispose();
    _otherInstalmentsController.dispose();
    _healthFitnessController.dispose();
    _skillsDevelopmentEducationController.dispose();
    _entertainmentSelfRewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

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
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(initialIndex: 0),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
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
                      Icons.arrow_back,
                      color: AppTheme.javaneseGoldLight,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Sisa Dana",
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

      body: Container(
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
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 17),
                _monthlyIncome(AuthService.currentUser),

                const SizedBox(height: 17),
                _categoryLivingExpenses(),

                const SizedBox(height: 17),
                _categorySavingInvestment(),

                const SizedBox(height: 17),
                _categoryInstalmentCommitment(),

                const SizedBox(height: 17),
                _categoryLifestyle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _categoryLifestyle() {
    return Container(
      height: 205,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppTheme.javanesesCream],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.javaneseGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.javaneseBrown.withValues(alpha: .2),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppTheme.javaneseGold.withValues(alpha: .1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 10,
            child: Text(
              "Gaya Hidup (10% dari pendapatan)",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 35,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    "Kesehatan & Olahraga (3%)",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _healthFitnessController,
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
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 90,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    "Pengembangan Skill & Pendidikan  (4%)",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _skillsDevelopmentEducationController,
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
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 145,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text("Hiburan (3%)", style: TextStyle(fontSize: 13)),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _entertainmentSelfRewardController,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _categoryInstalmentCommitment() {
    return Container(
      height: 205,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppTheme.javanesesCream],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.javaneseGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.javaneseBrown.withValues(alpha: .2),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppTheme.javaneseGold.withValues(alpha: .1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 10,
            child: Text(
              "Angsuran & Kewajiban (20% dari pendapatam)",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 35,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    "Angsuran Rumah dan atau Mobil (10%)",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _installmentsOutsideMortgagesController,
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
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 90,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    "Angsuran Kartu Kredit (jika ada) (5%)",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _creditCardInstalmentsController,
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
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 145,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    "Angsuran Lain (Elektronik, dll) (5%)",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _otherInstalmentsController,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _categorySavingInvestment() {
    return Container(
      height: 155,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppTheme.javanesesCream],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.javaneseGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.javaneseBrown.withValues(alpha: .2),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppTheme.javaneseGold.withValues(alpha: .1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 10,
            child: Text(
              "Tabungan & Investasi (20% dari pendapatan)",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            left: 10,
            right: 10,
            top: 35,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    "Dana Darurat (target terkumpul 6-12x pengeluaran bulanan) (5%)",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _emergencyFundController,
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
                ),
              ],
            ),
          ),

          Positioned(
            left: 10,
            right: 10,
            top: 90,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    "Investasi Jangka Panjang (Pensiun, Kebabasan Finansial) (15%)",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _longTermInvestmentController,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _categoryLivingExpenses() {
    return Container(
      height: 260,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppTheme.javanesesCream],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.javaneseGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.javaneseBrown.withValues(alpha: .2),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppTheme.javaneseGold.withValues(alpha: .1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 10,
            child: Text(
              "Biaya Hidup & Kewajiban (50% dari pendapatan)",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            left: 10,
            right: 10,
            top: 35,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    "Kebutuhan Rumah (listrik, air, internet, dll) (25%)",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _housingutilitiesController,
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
                ),
              ],
            ),
          ),

          Positioned(
            left: 10,
            right: 10,
            top: 90,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    "Makan & Transportasi (15%)",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _foodTransportController,
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
                ),
              ],
            ),
          ),

          Positioned(
            left: 10,
            right: 10,
            top: 145,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    "Asuransi Kesehatan (5%)",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _healthInsuranceController,
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
                ),
              ],
            ),
          ),

          Positioned(
            left: 10,
            right: 10,
            top: 200,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    "Pengeluaran Rutin Lain (5%)",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _otherRegularExpensesController,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding _monthlyIncome(User? user) {
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                "Bulan : ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _openMonthPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedMonth,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                "Pendapatan Bulan :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: TextFormField(
                  controller: _monthlyIncomeController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    CurrencyInputFormatter(
                      thousandSeparator: ThousandSeparator.Comma,
                      mantissaLength: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                "Sisa Dana :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(width: 75),
              Expanded(
                child: TextFormField(
                  controller: _remainingFundsController,
                  readOnly: true,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    CurrencyInputFormatter(
                      thousandSeparator: ThousandSeparator.Comma,
                      mantissaLength: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
