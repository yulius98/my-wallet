import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/data/models/allocation_post.dart';
import 'package:my_wallet/data/local/hive_boxes.dart';
import 'package:my_wallet/data/models/monthly_income.dart';
import 'package:my_wallet/presentation/widgets/common/custom_bottom_nav_bar.dart';
import 'package:my_wallet/services/auth_service.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/theme/app_theme.dart';
import 'package:my_wallet/core/utils/string_utils.dart';
import 'package:my_wallet/core/utils/currency_utils.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class WalletScreen extends StatefulWidget {
  final int initialIndex;
  const WalletScreen({super.key, this.initialIndex = 3});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late int _currentIndex;
  DateTime? _selectedDate;
  final TextEditingController _monthlyIncomeController =
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadMonthlyIncome();
  }

  void _loadMonthlyIncome() {
    final user = AuthService.currentUser;
    String userEmail = user?.email ?? 'unknown@email.com';

    // Load monthly income
    final monthlyIncome = boxMonthlyIncomes.get('key_income_$userEmail');
    if (monthlyIncome != null) {
      _monthlyIncomeController.text = CurrencyUtils.formatCurrency(
        monthlyIncome.income,
      );
    }

    // Map untuk menyederhanakan loading allocation data
    final allocationMap = {
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

    // Load semua allocation data dalam satu loop
    allocationMap.forEach((key, controller) {
      final allocation = boxAllocationPosts.get('key_${key}_$userEmail');
      if (allocation != null) {
        controller.text = CurrencyUtils.formatCurrency(allocation.amount);
      }
    });
  }

  @override
  void dispose() {
    _monthlyIncomeController.dispose();
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
          "Income Allocation",
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
                _cardpersonaldata(user),

                const SizedBox(height: 17),
                _monthlyincome(),

                const SizedBox(height: 17),
                _categoryLivingExpenses(),

                const SizedBox(height: 17),
                _categorySavingInvestment(),

                const SizedBox(height: 17),
                _categoryInstalmentCommitment(),

                const SizedBox(height: 17),
                _categoryLifestyle(),

                const SizedBox(height: 17),
                _saveAllocationPost(),
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
        borderRadius: BorderRadius.circular(14),
        color: AppTheme.cardBackground,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 10,
            child: Text(
              "Development & Lifestyle (10% from income)",
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
                const Text(
                  "Health & Fitness (3%)",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 18),
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
                      hintText: "Enter amount",
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
            top: 90,
            child: Row(
              children: [
                const Text(
                  "Skills & Education (4%)",
                  style: TextStyle(fontSize: 13),
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
                      hintText: "Enter amount",
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
            top: 145,
            child: Row(
              children: [
                const Text(
                  "Entertainment (3%)",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 32),
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
                      hintText: "Enter amount",
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

  Container _categoryInstalmentCommitment() {
    return Container(
      height: 205,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppTheme.cardBackground,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 10,
            child: Text(
              "Instalments & Commitments (20% from income)",
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
                const Text(
                  "Outside of Mortgages (10%)",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 12),
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
                      hintText: "Enter amount",
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
            top: 90,
            child: Row(
              children: [
                const Text(
                  "Credit Card Instalments (5%)",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 8),
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
                      hintText: "Enter amount",
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
            top: 145,
            child: Row(
              children: [
                const Text(
                  "Other Instalments (5%)",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 42),
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
                      hintText: "Enter amount",
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

  ElevatedButton _saveAllocationPost() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Warna background
        foregroundColor: Colors.white, // Warna teks
        padding: EdgeInsets.symmetric(vertical: 12),
        fixedSize: Size(370, 50), // Width: 370, Height: 50
        // Atau gunakan fixedSize untuk ukuran tetap:
        // fixedSize: Size(200, 50),
      ),
      onPressed: () {
        final user = AuthService.currentUser;
        String userEmail = user?.email ?? 'unknown@email.com';

        // Parse amount dari controller text menggunakan utility
        double incomeAmount = CurrencyUtils.parseAmount(
          _monthlyIncomeController.text,
        );
        double housingAmount = CurrencyUtils.parseAmount(
          _housingutilitiesController.text,
        );
        double foodAmount = CurrencyUtils.parseAmount(
          _foodTransportController.text,
        );
        double healthAmount = CurrencyUtils.parseAmount(
          _healthInsuranceController.text,
        );
        double otherexpanseAmount = CurrencyUtils.parseAmount(
          _otherRegularExpensesController.text,
        );
        double emergencyAmount = CurrencyUtils.parseAmount(
          _emergencyFundController.text,
        );
        double investmentAmount = CurrencyUtils.parseAmount(
          _longTermInvestmentController.text,
        );
        double installmentAmount = CurrencyUtils.parseAmount(
          _installmentsOutsideMortgagesController.text,
        );
        double creditcardAmount = CurrencyUtils.parseAmount(
          _creditCardInstalmentsController.text,
        );
        double otherInstallmentAmount = CurrencyUtils.parseAmount(
          _otherInstalmentsController.text,
        );
        double healthfitnessAmount = CurrencyUtils.parseAmount(
          _healthFitnessController.text,
        );
        double skillseducationAmount = CurrencyUtils.parseAmount(
          _skillsDevelopmentEducationController.text,
        );
        double entertaimentAmount = CurrencyUtils.parseAmount(
          _entertainmentSelfRewardController.text,
        );

        double totAllocation =
            housingAmount +
            foodAmount +
            healthAmount +
            otherexpanseAmount +
            emergencyAmount +
            investmentAmount +
            installmentAmount +
            creditcardAmount +
            otherInstallmentAmount +
            healthfitnessAmount +
            skillseducationAmount +
            entertaimentAmount;

        // Hitung selisih antara income dan total alokasi
        double difference = incomeAmount - totAllocation;

        // Validasi: cek apakah alokasi sudah sesuai dengan income
        if (difference != 0) {
          // Jika masih ada sisa atau kelebihan alokasi, tampilkan error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                difference > 0
                    ? 'There is still unallocated income amounting: Rp. ${NumberFormat('#,##0', 'id_ID').format(difference.abs())}'
                    : 'Total allocation exceeds income: Rp. ${NumberFormat('#,##0', 'id_ID').format(difference.abs())}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
          return; // Batalkan penyimpanan data
        }

        // Jika validasi lolos (difference == 0), simpan data
        setState(() {
          boxMonthlyIncomes.put(
            'key_income_$userEmail',
            MonthlyIncome(
              income: incomeAmount,
              date: _selectedDate ?? DateTime.now(),
            ),
          );
          boxAllocationPosts.put(
            'key_housing_$userEmail',
            AllocationPost(
              date: _selectedDate ?? DateTime.now(),
              email: userEmail,
              category: AppConstants.categoryHousing,
              amount: housingAmount,
            ),
          );
          boxAllocationPosts.put(
            'key_food_$userEmail',
            AllocationPost(
              date: _selectedDate ?? DateTime.now(),
              email: userEmail,
              category: AppConstants.categoryFood,
              amount: foodAmount,
            ),
          );
          boxAllocationPosts.put(
            'key_health_$userEmail',
            AllocationPost(
              date: _selectedDate ?? DateTime.now(),
              email: userEmail,
              category: AppConstants.categoryHealth,
              amount: healthAmount,
            ),
          );
          boxAllocationPosts.put(
            'key_otherexpense_$userEmail',
            AllocationPost(
              date: _selectedDate ?? DateTime.now(),
              email: userEmail,
              category: AppConstants.categoryOther,
              amount: otherexpanseAmount,
            ),
          );
          boxAllocationPosts.put(
            'key_emergency_$userEmail',
            AllocationPost(
              date: _selectedDate ?? DateTime.now(),
              email: userEmail,
              category: AppConstants.categoryEmergency,
              amount: emergencyAmount,
            ),
          );
          boxAllocationPosts.put(
            'key_investement_$userEmail',
            AllocationPost(
              date: _selectedDate ?? DateTime.now(),
              email: userEmail,
              category: AppConstants.categoryInvestment,
              amount: investmentAmount,
            ),
          );
          boxAllocationPosts.put(
            'key_installments_$userEmail',
            AllocationPost(
              date: _selectedDate ?? DateTime.now(),
              email: userEmail,
              category: AppConstants.categoryInstallments,
              amount: installmentAmount,
            ),
          );
          boxAllocationPosts.put(
            'key_creditcards_$userEmail',
            AllocationPost(
              date: _selectedDate ?? DateTime.now(),
              email: userEmail,
              category: AppConstants.categoryCreditCardInstalments,
              amount: creditcardAmount,
            ),
          );
          boxAllocationPosts.put(
            'key_otherInstallments_$userEmail',
            AllocationPost(
              date: _selectedDate ?? DateTime.now(),
              email: userEmail,
              category: AppConstants.categoryOtherInstalments,
              amount: otherInstallmentAmount,
            ),
          );
          boxAllocationPosts.put(
            'key_healths_$userEmail',
            AllocationPost(
              date: _selectedDate ?? DateTime.now(),
              email: userEmail,
              category: AppConstants.categoryHealthFitness,
              amount: healthfitnessAmount,
            ),
          );
          boxAllocationPosts.put(
            'key_skilleducation_$userEmail',
            AllocationPost(
              date: _selectedDate ?? DateTime.now(),
              email: userEmail,
              category: AppConstants.categorySkillsDevelopmentEducation,
              amount: skillseducationAmount,
            ),
          );
          boxAllocationPosts.put(
            'key_entertaiment_$userEmail',
            AllocationPost(
              date: _selectedDate ?? DateTime.now(),
              email: userEmail,
              category: AppConstants.categorySntertainmentSelfReward,
              amount: entertaimentAmount,
            ),
          );
        });

        // Menampilkan snackbar setelah data berhasil disimpan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data successfully saved!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                // Menutup snackbar saat tombol OK ditekan
              },
            ),
          ),
        );
      },
      child: const Text("Save Data"),
    );
  }

  Container _categorySavingInvestment() {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppTheme.cardBackground,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 10,
            child: Text(
              "Saving & Investment (20% from income)",
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
                const Text(
                  "Emergency Fund (5%)",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 55),
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
                      hintText: "Enter amount",
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
            top: 90,
            child: Row(
              children: [
                const Text(
                  "Long-term Investment (15%)",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 15),
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
                      hintText: "Enter amount",
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

  Container _categoryLivingExpenses() {
    return Container(
      height: 260,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppTheme.cardBackground,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 10,
            child: Text(
              "Living Expenses & Obligations (50% from income)",
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
                const Text(
                  "Housing & Utilities (25%)",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 32),
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
                      hintText: "Enter amount",
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
            top: 90,
            child: Row(
              children: [
                const Text(
                  "Food & Transport (15%)",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 40),
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
                      hintText: "Enter amount",
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
            top: 145,
            child: Row(
              children: [
                const Text(
                  "Health Insurance (5%)",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 50),
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
                      hintText: "Enter amount",
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
            top: 200,
            child: Row(
              children: [
                const Text(
                  "Other Regular Expenses (5%)",
                  style: TextStyle(fontSize: 13),
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
                      hintText: "Enter amount",
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

  Padding _monthlyincome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                "Date : ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 85),
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? "Choose Date"
                              : DateFormat('dd-MM-yyyy').format(_selectedDate!),
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedDate == null ? Colors.grey.shade600 : Colors.black,
                          ),
                        ),
                        Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                "Monthly Income",
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
                  decoration: InputDecoration(
                    hintText: "Enter amount",
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
          const SizedBox(height: 15),
          _calcIncomeAllocation(),
        ],
      ),
    );
  }

  ElevatedButton _calcIncomeAllocation() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: () {
        // Parse income menggunakan utility
        double income = CurrencyUtils.parseAmount(
          _monthlyIncomeController.text,
        );

        // Format dan set ke controller menggunakan utility dan constants
        _housingutilitiesController.text = CurrencyUtils.formatAllocation(
          income,
          AppConstants.housingPercentage,
        );
        _foodTransportController.text = CurrencyUtils.formatAllocation(
          income,
          AppConstants.foodTransportPercentage,
        );
        _healthInsuranceController.text = CurrencyUtils.formatAllocation(
          income,
          AppConstants.healthInsurancePercentage,
        );
        _otherRegularExpensesController.text = CurrencyUtils.formatAllocation(
          income,
          AppConstants.otherExpensesPercentage,
        );
        _emergencyFundController.text = CurrencyUtils.formatAllocation(
          income,
          AppConstants.emergencyFundPercentage,
        );
        _longTermInvestmentController.text = CurrencyUtils.formatAllocation(
          income,
          AppConstants.longTermInvestmentPercentage,
        );
        _installmentsOutsideMortgagesController.text =
            CurrencyUtils.formatAllocation(
              income,
              AppConstants.installmentsOutsideMortgages,
            );
        _creditCardInstalmentsController.text = CurrencyUtils.formatAllocation(
          income,
          AppConstants.creditCardInstalments,
        );
        _otherInstalmentsController.text = CurrencyUtils.formatAllocation(
          income,
          AppConstants.otherInstalments,
        );
        _healthFitnessController.text = CurrencyUtils.formatAllocation(
          income,
          AppConstants.healthFitness,
        );
        _skillsDevelopmentEducationController.text =
            CurrencyUtils.formatAllocation(
              income,
              AppConstants.skillsDevelopmentEducation,
            );
        _entertainmentSelfRewardController.text =
            CurrencyUtils.formatAllocation(
              income,
              AppConstants.entertainmentSelfReward,
            );
      },
      child: const Text("Income Allocation"),
    );
  }

  AspectRatio _cardpersonaldata(User? user) {
    return AspectRatio(
      aspectRatio: 336 / 120,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryDark,
              AppTheme.accentPurple.withAlpha(100),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 150,
              top: 10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.indigo[100],
                  image: user?.photoURL != null && user!.photoURL!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(user.photoURL!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user?.photoURL == null || user!.photoURL!.isEmpty
                    ? Icon(Icons.person, size: 50, color: Colors.indigo[700])
                    : null,
              ),
            ),
            Positioned(
              left: 150,
              top: 100,
              child: Text(
                StringUtils.getDisplayName(user?.displayName),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 85,
              top: 120,
              child: Text(
                'Email: ${StringUtils.formatEmail(user?.email)}',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
