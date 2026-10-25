import 'package:flutter/material.dart';
import 'package:sakuku/assets/color_apps.dart';
import 'package:sakuku/pages/form_page.dart';
import 'package:sakuku/widgets/curve_background.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: HeaderClipper(),
            child: Container(
              height: 340,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.balanceBlue
              ),
            ),
          ),
        SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(width: 24),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Catat Transaksi',
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Column(
                      spacing: 50,
                      children: [
                        // Pemasukan (Income)
                        _buildCards(Icons.arrow_upward,
                            "Pemasukan",
                            "Catat pemasukan uang kamu disini.",
                            AppColors.income,
                            Colors.white,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TransactionFormPage(
                                  type: 'pemasukan'
                                ))
                              );
                            }
                        ),
                        // Pengeluaran (Income)
                        _buildCards(
                            Icons.arrow_downward,
                            "Pengeluaran",
                            "Catat pengeluaran uang kamu disini.",
                            AppColors.expense,
                            Colors.white,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TransactionFormPage(
                                      type: 'pengeluaran'
                                  ))
                              );
                            }),
                      ],
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCards(
    IconData icon,
    String label,
    String secondaryLabel,
    Color backgroundColorsIcon,
    Color colorCard, {
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 800,
      height: 220,
      child: Material(
        color: colorCard,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: backgroundColorsIcon,
                  child: Icon(
                    icon,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                Text(
                  secondaryLabel,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
