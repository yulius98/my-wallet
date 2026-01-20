// lib/presentation/screens/home/home_screen.dart
import 'package:my_wallet/data/local/hive_boxes.dart';
import 'package:my_wallet/data/models/allocation_post.dart';
import 'package:my_wallet/presentation/widgets/common/custom_bottom_nav_bar.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/theme/app_theme.dart';
import 'package:my_wallet/core/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_wallet/services/auth_service.dart';
import 'package:intl/intl.dart';
//import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // Debug logging untuk verifikasi data saat home screen dibuka
    final user = AuthService.currentUser;
    debugPrint('🏠 HomeScreen initialized for: ${user?.email}');
    debugPrint('🏠 Total allocations in box: ${boxAllocationPosts.length}');
    debugPrint('🏠 Total incomes in box: ${boxMonthlyIncomes.length}');

    // List semua keys untuk debugging
    if (boxAllocationPosts.isNotEmpty) {
      debugPrint('🏠 Allocation keys:');
      for (var key in boxAllocationPosts.keys.take(5)) {
        debugPrint('   - $key');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
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
                    Icons.account_balance_wallet,
                    color: AppTheme.javaneseGoldLight,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  AppConstants.appName,
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
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppTheme.javaneseMaroon.withValues(alpha: .8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.javaneseGold.withValues(alpha: .5),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: AppTheme.javaneseGoldLight,
                  ),
                  onPressed: () async {
                    await AuthService.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                ),
              ),
            ],
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
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConstants.backgroundPath),
              fit: BoxFit.cover,
              opacity: 0.15,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _greeting(context, user),

                const SizedBox(height: 20),
                _card(user),

                const SizedBox(height: 20),
                _listcategory(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded _listcategory() {
    final user = AuthService.currentUser;
    final userEmail = user?.email ?? '';
    
    // Debug logging
    debugPrint('📊 Loading allocations for: $userEmail');
    debugPrint('📊 Total items in box: ${boxAllocationPosts.length}');
    debugPrint('📊 Current date: ${DateTime.now()}');
    
    // Filter allocation posts by current user's email
    final userAllocations = boxAllocationPosts.values
        .where(
          (allocation) {
      final matches =
          allocation.email == userEmail &&
          allocation.date.year == DateTime.now().year &&
          allocation.date.month == DateTime.now().month;

      if (matches) {
        debugPrint(
          '✅ Found allocation: ${allocation.category} - ${allocation.amount}',
        );
      }

      return matches;
    },
        )
        .toList();
    
    debugPrint('📊 Total filtered allocations: ${userAllocations.length}');
        
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: AppTheme.javaneseGoldGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Alokasi Dana',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.javaneseBrown,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: userAllocations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 80,
                          color: AppTheme.javaneseBrown.withValues(alpha: .3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada alokasi dana',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.javaneseBrown.withValues(alpha: .6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: userAllocations.length,
                    itemBuilder: (context, index) {
                      AllocationPost allocationPost = userAllocations[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              AppTheme.javanesesCream.withValues(alpha: .5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.javaneseGold.withValues(alpha: .3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.javaneseBrown.withValues(
                                alpha: .1,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppTheme.javaneseGoldGradient,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.javaneseGold,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.javaneseGold.withValues(
                                    alpha: .3,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: AppTheme.javaneseBrown,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            allocationPost.category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.javaneseBrown,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Rp ${NumberFormat('#,##0', 'id_ID').format(allocationPost.amount)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.javaneseMaroon,
                              ),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.javaneseGold.withValues(
                                alpha: .2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.javaneseGold.withValues(
                                  alpha: .5,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppTheme.javaneseBrown,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  AspectRatio _card(User? user) {
    final userEmail = user?.email ?? '';
    final now = DateTime.now();

    // Filter income berdasarkan email user dan bulan/tahun saat ini
    final filteredIncomes = boxMonthlyIncomes.values.where(
      (income) =>
          income.email == userEmail &&
          income.date.year == now.year &&
          income.date.month == now.month,
    );

    final incomeAmount = filteredIncomes.isNotEmpty
        ? filteredIncomes.first.income
        : 0.0;
    
    return AspectRatio(
      aspectRatio: 336 / 200,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: AppTheme.javaneseBrownGradient,
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            children: [
              // Ornamen background
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    AppConstants.backgroundCard,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Ornamen border dalam
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.javaneseGold.withValues(alpha: .3),
                      width: 1,
                    ),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat("MMMM yyyy").format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.javaneseGoldLight,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 2,
                              width: 60,
                              decoration: BoxDecoration(
                                gradient: AppTheme.javaneseGoldGradient,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.javaneseGold,
                              width: 3,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.javaneseGold.withValues(alpha: .3),
                                AppTheme.javaneseBrownLight,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.javaneseGold.withValues(
                                  alpha: .3,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            image:
                                user?.photoURL != null &&
                                    user!.photoURL!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(user.photoURL!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              user?.photoURL == null || user!.photoURL!.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppTheme.javaneseGoldLight,
                                )
                              : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),
                    Text(
                      "Pendapatan Bulanan",
                      style: TextStyle(
                        color: AppTheme.javaneseGoldLight.withValues(alpha: .8),
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Rp ${NumberFormat('#,##0', 'id_ID').format(incomeAmount)}",
                      style: const TextStyle(
                        color: AppTheme.javaneseGoldLight,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dana Tersedia",
                              style: TextStyle(
                                color: AppTheme.javaneseGoldLight.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rp 0",
                              style: TextStyle(
                                color: AppTheme.javaneseGoldLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.javaneseGoldGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.javaneseGold.withValues(
                                  alpha: .3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            user?.email?.split('@')[0] ?? "",
                            style: const TextStyle(
                              color: AppTheme.javaneseBrown,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _greeting(BuildContext context, User? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.javaneseGoldGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.javaneseGold.withValues(alpha: .3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.waving_hand,
                color: AppTheme.javaneseBrown,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sugeng Rawuh",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.javaneseBrown.withValues(alpha: .7),
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    StringUtils.getDisplayName(user?.displayName),
                    style: const TextStyle(
                      fontSize: 22,
                      color: AppTheme.javaneseBrown,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
