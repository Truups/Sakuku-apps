import 'package:flutter/material.dart';
import 'package:sakuku/assets/color_apps.dart';
import 'package:sakuku/models/transaction_model.dart';
import 'package:sakuku/repositories/transaction_repository.dart';
import 'package:sakuku/widgets/curve_background.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  late Future<List<TransactionModel>> _futureTransactions;

  @override
  void initState() {
    super.initState();
    _futureTransactions = TransactionRepository.getListTransactions();
    TransactionRepository.revision.addListener(_reload);
  }

  @override
  void dispose() {
    TransactionRepository.revision.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _futureTransactions = TransactionRepository.getListTransactions();
    });
  }

  double _totalByType(List<TransactionModel> items, String type) {
    return items
        .where((item) => item.type == type)
        .fold(0.0, (total, item) => total + item.amount);
  }

  String _formatRupiah(double value) {
    final isNegative = value < 0;
    final digits = value.abs().round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    return '${isNegative ? '-' : ''}Rp $buffer';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            ClipPath(
              clipper: HeaderClipper(),
              child: Container(
                height: 340,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.balanceBlue,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FutureBuilder<List<TransactionModel>>(
                  future: _futureTransactions,
                  builder: (context, snapshot) {
                    final transactions = snapshot.data ?? <TransactionModel>[];
                    final income = _totalByType(transactions, 'pemasukan');
                    final expense = _totalByType(transactions, 'pengeluaran');
                    final balance = income - expense;
                    final isLoading =
                        snapshot.connectionState == ConnectionState.waiting;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Halo, Abel',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Semangat hari ini!',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          'Total Saldo',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              height: 28,
                              width: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else if (snapshot.hasError)
                          const Text(
                            'Gagal memuat data',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          )
                        else
                          Text(
                            _formatRupiah(balance),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),

                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.incomeText,
                                child: Icon(Icons.arrow_downward, color: Colors.white,),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pemasukan',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      _formatRupiah(income),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 36,
                                child: VerticalDivider(
                                  width: 40,
                                  thickness: 1,
                                  indent: 2,
                                  endIndent: 2,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.expenseText,
                                child: Icon(Icons.arrow_upward, color: Colors.white,),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pengeluaran',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatRupiah(expense),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ===== Daftar transaksi terbaru =====
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Transaksi Terbaru',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1B2A4E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (isLoading)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (transactions.isEmpty)
                                Center(
                                  child:
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 100,),
                                        Icon(Icons.no_sim_rounded, color: AppColors.textSecondary, size: 100,),
                                        SizedBox(height: 24,),
                                        Text(
                                          "Belum ada transaksi terbaru yang tercatat.",
                                          style:
                                          TextStyle(
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                              fontSize: 14
                                          )
                                          ,)
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...transactions
                                    .take(5)
                                    .map(_buildTransactionItem),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final isIncome = transaction.type == 'pemasukan';
    final notes = transaction.notes?.trim() ?? '';
    final subtitle = notes.isEmpty
        ? _formatDate(transaction.createdAt)
        : '${_formatDate(transaction.createdAt)} · $notes';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isIncome
                ? AppColors.incomeIconBg
                : const Color(0xFFFFE5E7),
            child: Icon(
              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              size: 18,
              color: isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isIncome ? '+' : '-'} ${_formatRupiah(transaction.amount)}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isIncome ? AppColors.incomeText : AppColors.expenseText,
            ),
          ),
        ],
      ),
    );
  }
}