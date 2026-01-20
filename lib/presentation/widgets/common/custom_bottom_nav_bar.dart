import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/core/theme/app_theme.dart';
import 'package:my_wallet/presentation/screens/history_trasaction_screen.dart';
import 'package:my_wallet/presentation/screens/home_screen.dart';
import 'package:my_wallet/presentation/screens/transaction_screen.dart';
import 'package:my_wallet/presentation/screens/wallet_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTab;
  final dynamic user;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTab,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Icon(Icons.home, color: AppTheme.javaneseGoldLight, size: 20),
      Icon(Icons.payment, color: AppTheme.javaneseGoldLight, size: 20),
      Icon(Icons.history, color: AppTheme.javaneseGoldLight, size: 20),
      Icon(Icons.wallet, color: AppTheme.javaneseGoldLight, size: 20),
      Icon(Icons.settings, color: AppTheme.javaneseGoldLight, size: 20),
    ];

    return CurvedNavigationBar(
      items: items,
      index: currentIndex,
      onTap: (index) {
        onTab(index); // update index di parent
        if (index == 0) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HomeScreen(initialIndex: index),
            ),
          );
        }
        if (index == 1) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TransactionScreen(initialIndex: index),
            ),
          );
        }
        if (index == 2) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HistoryTrasactionScreen(initialIndex: index)
            ),  
          );
        }

        if (index == 3) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WalletScreen(initialIndex: index),
            ),
          );
        }
      },
      backgroundColor: AppTheme.javaneseGreen,
      color: AppTheme.javaneseBrown,
      buttonBackgroundColor: Colors.transparent,
      height: 55,
      animationDuration: const Duration(milliseconds: 300),
    );
  }
}
