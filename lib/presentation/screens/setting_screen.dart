import 'package:my_wallet/data/local/hive_boxes.dart';
import 'package:my_wallet/presentation/screens/sisa_dana_screen.dart';
import 'package:my_wallet/presentation/widgets/common/custom_bottom_nav_bar.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_wallet/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/presentation/screens/panduan_aplikasi.dart';

class SettingScreen extends StatefulWidget {
  final int initialIndex;
  const SettingScreen({super.key, this.initialIndex = 4});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late int _currentIndex;
  final user = AuthService.currentUser;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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
                    Icons.settings,
                    color: AppTheme.javaneseGoldLight,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Setting",
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
                const SizedBox(height: 12),
                _card(user),

                const SizedBox(height: 60),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SisaDanaScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          AppTheme.javanesesCream.withValues(alpha: .5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.javaneseGold.withValues(alpha: .8),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.javaneseBrown.withValues(alpha: .1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.stacked_line_chart,
                          color: AppTheme.javaneseMaroon,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Sisa Dana",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.javaneseBrown,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.javaneseBrown.withValues(alpha: .6),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _hapusData(),

                const SizedBox(height: 20),
                _panduanAplikasi(),

                const SizedBox(height: 20),
                _logout(),
                const SizedBox(
                  height: 20,
                ), // Padding bawah agar tidak tertutup bottom nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logout() {
    return InkWell(
      onTap: () async {
        // Tampilkan dialog konfirmasi
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keluar Aplikasi'),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Keluar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        // Jika user memilih keluar
        if (shouldLogout == true) {
          await AuthService.signOut();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppTheme.javanesesCream.withValues(alpha: .5),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.javaneseGold.withValues(alpha: .8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.javaneseBrown.withValues(alpha: .1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.logout, color: AppTheme.javaneseMaroon, size: 24),
            const SizedBox(width: 12),
            Text(
              "Keluar Aplikasi",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.javaneseBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _panduanAplikasi() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PanduanAplikasiScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppTheme.javanesesCream.withValues(alpha: .5),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.javaneseGold.withValues(alpha: .8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.javaneseBrown.withValues(alpha: .1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.help_outline, color: AppTheme.javaneseMaroon, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Panduan Aplikasi",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.javaneseBrown,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.javaneseBrown.withValues(alpha: .6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _hapusData() {
    return InkWell(
      onTap: () async {
        // Tampilkan dialog konfirmasi
        final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Semua Data'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus semua data? '
              'Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        // Jika user memilih hapus
        if (shouldDelete == true) {
          try {
            // Hapus semua data di semua box
            await boxAllocationPosts.clear();
            await boxTransactions.clear();
            await boxMonthlyIncomes.clear();
            await boxInitialAllocations.clear();

            if (mounted) {
              // Tampilkan snackbar sukses
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua data berhasil dihapus'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );

              // Refresh halaman
              setState(() {});
            }
          } catch (e) {
            if (mounted) {
              // Tampilkan snackbar error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal menghapus data: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppTheme.javanesesCream.withValues(alpha: .5),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.javaneseGold.withValues(alpha: .8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.javaneseBrown.withValues(alpha: .1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.delete_outline,
              color: AppTheme.javaneseMaroon,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              "Hapus Data",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.javaneseBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(User? user) {
    final userEmail = user?.email ?? '';
    final now = DateTime.now();

    final totalTransaksi = boxTransactions.values
        .where(
          (transaction) =>
              transaction.email == userEmail &&
              transaction.date.year == now.year &&
              transaction.date.month == now.month,
        )
        .fold<double>(0.0, (sum, transaction) => sum + transaction.amount);

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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Gunakan aspect ratio yang lebih kecil pada layar dengan tinggi terbatas
        final screenHeight = MediaQuery.of(context).size.height;
        final aspectRatio = screenHeight < 700 ? 336 / 180 : 336 / 200;

        return AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppConstants.backgroundCard),
                fit: BoxFit.cover,
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
            child: LayoutBuilder(
              builder: (context, cardConstraints) {
                // Hitung scaling factor berdasarkan lebar card
                final cardWidth = cardConstraints.maxWidth;
                final cardHeight = cardConstraints.maxHeight;

                // Base scaling dari lebar card (336 adalah lebar base)
                final scale = cardWidth / 336;

                return Stack(
                  children: [
                    // Tanggal - responsive position & size
                    Positioned(
                      left: cardWidth * 0.03,
                      top: cardHeight * 0.05,
                      child: Text(
                        DateFormat("MMMM yyyy").format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 14 * scale,
                          color: AppTheme.javaneseGoldLight,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    // Profile photo - responsive size & position
                    Positioned(
                      right: cardWidth * 0.035,
                      top: cardHeight * 0.2,
                      child: Container(
                        width: cardWidth * 0.24,
                        height: cardWidth * 0.24,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20 * scale),
                          border: Border.all(
                            color: AppTheme.javaneseGold,
                            width: 3 * scale,
                          ),
                          image:
                              user?.photoURL != null &&
                                  user!.photoURL!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(user.photoURL!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user?.photoURL == null || user!.photoURL!.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 50 * scale,
                                color: AppTheme.javaneseGold,
                              )
                            : null,
                      ),
                    ),

                    // Label "Pendapatan Bulan Ini" - responsive
                    Positioned(
                      left: cardWidth * 0.03,
                      top: cardHeight * 0.3,
                      right: cardWidth * 0.3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Pendapatan Bulan Ini",
                          style: TextStyle(
                            color: AppTheme.javaneseGoldLight.withValues(
                              alpha: .8,
                            ),
                            fontSize: 13 * scale,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Jumlah pendapatan - responsive
                    Positioned(
                      left: cardWidth * 0.03,
                      top: cardHeight * 0.4,
                      right: cardWidth * 0.3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Rp ${NumberFormat('#,##0', 'id_ID').format(incomeAmount)}",
                          style: TextStyle(
                            color: AppTheme.javaneseGoldLight,
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            shadows: const [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Label "Dana yang Bisa Digunakan" - responsive
                    Positioned(
                      left: cardWidth * 0.15,
                      top: cardHeight * 0.6,
                      right: cardWidth * 0.05,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Dana yang Bisa Digunakan :",
                          style: TextStyle(
                            color: AppTheme.javaneseGoldLight,
                            fontSize: 13 * scale,
                          ),
                        ),
                      ),
                    ),

                    // Jumlah dana tersisa - responsive
                    Positioned(
                      left: cardWidth * 0.19,
                      top: cardHeight * 0.7,
                      right: cardWidth * 0.05,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Rp ${NumberFormat('#,##0', 'id_ID').format(incomeAmount - totalTransaksi)}",
                          style: TextStyle(
                            color: AppTheme.javaneseGoldLight,
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
