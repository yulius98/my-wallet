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

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
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
          child: Column(
            children: [
              const SizedBox(height: 15),
              _greeting(context, user),

              const SizedBox(height: 15),
              _card(user),

              const SizedBox(height: 15),
              _listcategory(),
            ],
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
      child: ListView.builder(
        itemCount: userAllocations.length,
        itemBuilder: (context, index) {
          AllocationPost allocationPost = userAllocations[index];
          return ListTile(
            leading: IconButton(
              onPressed: () {

              }, 
              icon: const Icon(
                Icons.add,
              ),
              ),
            title: Text(allocationPost.category, 
              style: TextStyle(
                fontWeight: FontWeight.bold    
              ),
            ),
            //subtitle: const Text('Category'),
            trailing: Text('Amount: Rp. ${NumberFormat('#,##0', 'id_ID').format(allocationPost.amount)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold
              ),
            ),
          );
        },
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
      aspectRatio: 336 / 184,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppTheme.primaryDark,
        ),
        
        child: Stack(
          children: [
            Positioned(
              left: 15,
              top: 20,
              child: Text(
                DateFormat("MMMM yyyy").format(DateTime.now()),
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            Positioned(
              left: 15,
              top: 60,
              child: Text(
                "Total Income",
                style: const TextStyle(color: Colors.white),
              ),
            ),

            Positioned(
              left: 15,
              top: 80,
              child: Text(
                "IDR: ${NumberFormat('#,##0', 'id_ID').format(incomeAmount)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Positioned(
              left: 15,
              top: 120,
              child: Text(
                "Available Funds",
                style: const TextStyle(color: Colors.white),
              ),
            ),

            Positioned(
              left: 15,
              top: 140,
              child: Text("IDR: ", style: const TextStyle(color: Colors.white)),
            ),

            Positioned(
              left: 15,
              top: 200,
              child: Text(
                user?.email ?? "",
                style: const TextStyle(color: Colors.white),
              ),
            ),

            Positioned(
              right: 20,
              top: 50,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
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
          ],
        ),
      ),
    );
  }

  Padding _greeting(BuildContext context, User? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text("Welcome Back !", style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              StringUtils.getDisplayName(user?.displayName),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
