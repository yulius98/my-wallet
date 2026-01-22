import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/data/models/allocation_post.dart';
import 'package:my_wallet/data/local/hive_boxes.dart';
import 'package:my_wallet/data/models/initial_allocation.dart';
import 'package:my_wallet/data/models/monthly_income.dart';
import 'package:my_wallet/presentation/widgets/common/custom_bottom_nav_bar.dart';
import 'package:my_wallet/services/auth_service.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/theme/app_theme.dart';
import 'package:my_wallet/core/utils/string_utils.dart';
import 'package:my_wallet/core/utils/currency_utils.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:my_wallet/presentation/widgets/common/month_picker_bottom_sheet.dart';

class WalletScreen extends StatefulWidget {
  final int initialIndex;
  const WalletScreen({super.key, this.initialIndex = 3});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late int _currentIndex;
  DateTime _selectedMonth = DateTime.now();
  bool _isEditMode = false;
  bool _isDataSaved = false;

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

  String get formattedMonth {
    return DateFormat('MMMM yyyy').format(_selectedMonth);
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
      // Data sudah ada di database, tandai sebagai saved
      setState(() {
        _isDataSaved = true;
        _isEditMode = false;
      });
    } else {
      _monthlyIncomeController.clear();
      // Data belum ada, tandai sebagai belum saved
      setState(() {
        _isDataSaved = false;
        _isEditMode = false;
      });
    }

    // Map untuk menyederhanakan loading allocation data
    final initalAllocationMap = {
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
    initalAllocationMap.forEach((key, controller) {
      final initialAllocation = boxInitialAllocations.get(
        'key_${key}_${userEmail}_$monthYearKey',
      );
      if (initialAllocation != null) {
        controller.text = CurrencyUtils.formatCurrency(
          initialAllocation.amount,
        );
      } else {
        controller.clear();
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

  @override
  Widget build(BuildContext context) {
    debugPrint("Status Edit Mode : $_isEditMode");
    debugPrint("Status Save Data : $_isDataSaved");
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
                    Icons.pie_chart_rounded,
                    color: AppTheme.javaneseGoldLight,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Alokasi Pendapatan",
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
                _actionButtons(),
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
                      hintText: "Masukkan jumlah",
                      filled: _isEditMode,
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
                      hintText: "Masukkan jumlah",
                      filled: _isEditMode,
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
                      hintText: "Masukkan Jumlah",
                      filled: _isEditMode,
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
                      hintText: "Masukkan Jumlah",
                      filled: _isEditMode,
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
                      hintText: "Masukkan Jumlah",
                      filled: _isEditMode,
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
                      hintText: "Masukkan Jumlah",
                      filled: _isEditMode,
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(0, 50),
      ),
      onPressed: _isDataSaved
          ? null
          : () {
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
                    ? 'Masih terdapat pendapatan yang belum dialokasikan sebesar: Rp. ${NumberFormat('#,##0', 'id_ID').format(difference.abs())}'
                    : 'Total alokasi melebihi pendapatan: Rp. ${NumberFormat('#,##0', 'id_ID').format(difference.abs())}',
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
        // Format bulan-tahun untuk key (contoh: 202601 untuk Januari 2026)
        String monthYearKey =
            '${_selectedMonth.year}${_selectedMonth.month.toString().padLeft(2, '0')}';

        // Simpan data ke Hive
        boxMonthlyIncomes.put(
          'key_income_${userEmail}_$monthYearKey',
          MonthlyIncome(
            email: userEmail,
            date: _selectedMonth,
            income: incomeAmount,
          ),
        );
        boxAllocationPosts.put(
          'key_housing_${userEmail}_$monthYearKey',
          AllocationPost(
            date: _selectedMonth,
            email: userEmail,
            category: AppConstants.categoryHousing,
            amount: housingAmount,
          ),
        );
        boxAllocationPosts.put(
          'key_food_${userEmail}_$monthYearKey',
          AllocationPost(
            date: _selectedMonth,
            email: userEmail,
            category: AppConstants.categoryFood,
            amount: foodAmount,
          ),
        );
        boxAllocationPosts.put(
          'key_health_${userEmail}_$monthYearKey',
          AllocationPost(
            date: _selectedMonth,
            email: userEmail,
            category: AppConstants.categoryHealth,
            amount: healthAmount,
          ),
        );
        boxAllocationPosts.put(
          'key_otherexpense_${userEmail}_$monthYearKey',
          AllocationPost(
            date: _selectedMonth,
            email: userEmail,
            category: AppConstants.categoryOther,
            amount: otherexpanseAmount,
          ),
        );
        boxAllocationPosts.put(
          'key_emergency_${userEmail}_$monthYearKey',
          AllocationPost(
            date: _selectedMonth,
            email: userEmail,
            category: AppConstants.categoryEmergency,
            amount: emergencyAmount,
          ),
        );
        boxAllocationPosts.put(
          'key_investement_${userEmail}_$monthYearKey',
          AllocationPost(
            date: _selectedMonth,
            email: userEmail,
            category: AppConstants.categoryInvestment,
            amount: investmentAmount,
          ),
        );
        boxAllocationPosts.put(
          'key_installments_${userEmail}_$monthYearKey',
          AllocationPost(
            date: _selectedMonth,
            email: userEmail,
            category: AppConstants.categoryInstallments,
            amount: installmentAmount,
          ),
        );
        boxAllocationPosts.put(
          'key_creditcards_${userEmail}_$monthYearKey',
          AllocationPost(
            date: _selectedMonth,
            email: userEmail,
            category: AppConstants.categoryCreditCardInstalments,
            amount: creditcardAmount,
          ),
        );
        boxAllocationPosts.put(
          'key_otherInstallments_${userEmail}_$monthYearKey',
          AllocationPost(
            date: _selectedMonth,
            email: userEmail,
            category: AppConstants.categoryOtherInstalments,
            amount: otherInstallmentAmount,
          ),
        );
        boxAllocationPosts.put(
          'key_healths_${userEmail}_$monthYearKey',
          AllocationPost(
            date: _selectedMonth,
            email: userEmail,
            category: AppConstants.categoryHealthFitness,
            amount: healthfitnessAmount,
          ),
        );
        boxAllocationPosts.put(
          'key_skilleducation_${userEmail}_$monthYearKey',
          AllocationPost(
            date: _selectedMonth,
            email: userEmail,
            category: AppConstants.categorySkillsDevelopmentEducation,
            amount: skillseducationAmount,
          ),
        );
        boxAllocationPosts.put(
          'key_entertaiment_${userEmail}_$monthYearKey',
          AllocationPost(
            date: _selectedMonth,
            email: userEmail,
            category: AppConstants.categorySntertainmentSelfReward,
            amount: entertaimentAmount,
          ),
        );

              boxInitialAllocations.put(
                'key_housing_${userEmail}_$monthYearKey',
                InitialAllocation(
                  date: _selectedMonth,
                  email: userEmail,
                  category: AppConstants.categoryHousing,
                  amount: housingAmount,
                ),
              );
              boxInitialAllocations.put(
                'key_food_${userEmail}_$monthYearKey',
                InitialAllocation(
                  date: _selectedMonth,
                  email: userEmail,
                  category: AppConstants.categoryFood,
                  amount: foodAmount,
                ),
              );
              boxInitialAllocations.put(
                'key_health_${userEmail}_$monthYearKey',
                InitialAllocation(
                  date: _selectedMonth,
                  email: userEmail,
                  category: AppConstants.categoryHealth,
                  amount: healthAmount,
                ),
              );
              boxInitialAllocations.put(
                'key_otherexpense_${userEmail}_$monthYearKey',
                InitialAllocation(
                  date: _selectedMonth,
                  email: userEmail,
                  category: AppConstants.categoryOther,
                  amount: otherexpanseAmount,
                ),
              );
              boxInitialAllocations.put(
                'key_emergency_${userEmail}_$monthYearKey',
                InitialAllocation(
                  date: _selectedMonth,
                  email: userEmail,
                  category: AppConstants.categoryEmergency,
                  amount: emergencyAmount,
                ),
              );
              boxInitialAllocations.put(
                'key_investement_${userEmail}_$monthYearKey',
                InitialAllocation(
                  date: _selectedMonth,
                  email: userEmail,
                  category: AppConstants.categoryInvestment,
                  amount: investmentAmount,
                ),
              );
              boxInitialAllocations.put(
                'key_installments_${userEmail}_$monthYearKey',
                InitialAllocation(
                  date: _selectedMonth,
                  email: userEmail,
                  category: AppConstants.categoryInstallments,
                  amount: installmentAmount,
                ),
              );
              boxInitialAllocations.put(
                'key_creditcards_${userEmail}_$monthYearKey',
                InitialAllocation(
                  date: _selectedMonth,
                  email: userEmail,
                  category: AppConstants.categoryCreditCardInstalments,
                  amount: creditcardAmount,
                ),
              );
              boxInitialAllocations.put(
                'key_otherInstallments_${userEmail}_$monthYearKey',
                InitialAllocation(
                  date: _selectedMonth,
                  email: userEmail,
                  category: AppConstants.categoryOtherInstalments,
                  amount: otherInstallmentAmount,
                ),
              );
              boxInitialAllocations.put(
                'key_healths_${userEmail}_$monthYearKey',
                InitialAllocation(
                  date: _selectedMonth,
                  email: userEmail,
                  category: AppConstants.categoryHealthFitness,
                  amount: healthfitnessAmount,
                ),
              );
              boxInitialAllocations.put(
                'key_skilleducation_${userEmail}_$monthYearKey',
                InitialAllocation(
                  date: _selectedMonth,
                  email: userEmail,
                  category: AppConstants.categorySkillsDevelopmentEducation,
                  amount: skillseducationAmount,
                ),
              );
              boxInitialAllocations.put(
                'key_entertaiment_${userEmail}_$monthYearKey',
                InitialAllocation(
                  date: _selectedMonth,
                  email: userEmail,
                  category: AppConstants.categorySntertainmentSelfReward,
                  amount: entertaimentAmount,
                ),
              );

        // Force flush data ke disk untuk memastikan data benar-benar tersimpan
        boxMonthlyIncomes.flush();
        boxAllocationPosts.flush();
              boxInitialAllocations.flush();

        // Debug logging untuk verifikasi
        debugPrint('💾 Data saved for $userEmail - Month: $monthYearKey');
        debugPrint(
          '💾 Total items in boxAllocationPosts: ${boxAllocationPosts.length}',
        );
        debugPrint(
          '💾 Total items in boxMonthlyIncomes: ${boxMonthlyIncomes.length}',
        );
              debugPrint(
                '💾 Total items in boxInitialAllocation: ${boxInitialAllocations.length}',
              );

        setState(() {
          // Trigger rebuild untuk update UI
          _isDataSaved = true;
          _isEditMode = false;
        });

        // Menampilkan snackbar setelah data berhasil disimpan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data berhasil disimpan!'),
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
      child: const Text("Simpan Data"),
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _saveAllocationPost()),
          const SizedBox(width: 12),
          Expanded(child: _editDataButton()),
        ],
      ),
    );
  }

  ElevatedButton _editDataButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _isDataSaved ? Colors.grey : Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(0, 50),
      ),

      onPressed: _isDataSaved
          ? null
          : () {
              _editData();
            },
      child: Text(_isEditMode ? "Batal Edit" : "Edit Data"),
    );
  }

  void _editData() {
    setState(() {
      _isEditMode = !_isEditMode;
      debugPrint("🔄 Edit mode changed to: $_isEditMode");
    });

    if (_isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mode edit diaktifkan'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mode edit dinonaktifkan'),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                      hintText: "Masukkan Jumlah",
                      filled: _isEditMode,
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
                      hintText: "Masukkan Jumlah",
                      filled: _isEditMode,
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
                      hintText: "Masukkan Jumlah",
                      filled: _isEditMode,
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
                      hintText: "Masukkan Jumlah",
                      filled: _isEditMode,
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
                      hintText: "Masukkan Jumlah",
                      filled: _isEditMode,
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
                      hintText: "Masukkan Jumlah",
                      filled: _isEditMode,
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
                "Bulan : ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
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
                "Pendapatan Bulanan",
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
                    hintText: "Masukkan Jumlah",
                    filled: _isEditMode,
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
      onPressed: _isDataSaved
          ? null
          : () {
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
      child: const Text("Alokasi Pendapatan"),
    );
  }

  AspectRatio _cardpersonaldata(User? user) {
    return AspectRatio(
      aspectRatio: 336 / 120,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.backgroundCard),
            fit: BoxFit.cover,
          ),
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
