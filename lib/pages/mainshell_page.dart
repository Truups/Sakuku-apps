import "package:flutter/material.dart";
import "package:sakuku/assets/color_apps.dart";
import "package:sakuku/pages/balance_page.dart";
import "package:sakuku/pages/history_page.dart";
import "package:sakuku/pages/information_page.dart";
import "package:sakuku/pages/statistic_page.dart";
import "package:sakuku/pages/transaction_page.dart";


class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;
  static const List<Widget>_pages = [
    BalancePage(),
    HistoryPage(),
    StatisticPage(),
    InformationPage()
  ];

  void _onTabSelected(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
            _buildNavItem(Icons.home_rounded, 'Beranda', 0),
            _buildNavItem(Icons.history, 'Riwayat', 1),
            _buildFAB(),
            _buildNavItem(Icons.bar_chart_outlined, 'Statistik', 2),
            _buildNavItem(Icons.info_outline, 'Informasi', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    final color = isActive ? AppColors.balanceBlue : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onTabSelected(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFAB() {
    return Expanded(
      child: Center(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.balanceBlue,
            shape: BoxShape.circle,
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 4,
            shape: const CircleBorder(),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionPage())
              );
            },
            tooltip: 'Tambah Data',
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
