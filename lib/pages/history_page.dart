import "package:flutter/material.dart";
import "package:sakuku/models/transaction_model.dart";
import "package:sakuku/widgets/curve_background.dart";
import "package:sakuku/assets/color_apps.dart";
import "package:sakuku/repositories/transaction_repository.dart";

enum TransactionFilter {
  semua('Semua', null),
  pemasukan('Pemasukan', 'pemasukan'),
  pengeluaran('Pengeluaran', 'pengeluaran');

  const TransactionFilter(this.label, this.dbValue);
  final String label;
  final String? dbValue;
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>{
  late Future<List<TransactionModel>> _futureListTransactions;
  DateTime _dateOnly(DateTime day) => DateTime(day.year, day.month, day.day);

  @override
  void initState(){
    super.initState();
    _futureListTransactions = _fetchTransactions();
    TransactionRepository.revision.addListener(_reload);
  }

  @override
  void dispose() {
    TransactionRepository.revision.removeListener(_reload);
    super.dispose();
  }

  void _reload(){
    if(!mounted) return;
    setState(() {
      _futureListTransactions = _fetchTransactions();
    });
  }

  Future<List<TransactionModel>> _fetchTransactions(){
    return TransactionRepository.getListTransactions(type: _selectedFilter.dbValue);
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

  String _formatGroupLabel(DateTime date){
    final today = _dateOnly(DateTime.now());
    final diffDay = today.difference(date).inDays;

    if(diffDay == 0) return 'Hari ini';
    if(diffDay == 1) return 'Kemarin';
    return _formatDate(date);
  }

  Map<DateTime, List<TransactionModel>> _groupedByDate(List<TransactionModel> transactions){
    final data = [...transactions];
    final Map<DateTime, List<TransactionModel>> grouped = {};
    for (final i in data){
      final keys = _dateOnly(i.createdAt);
      grouped.putIfAbsent(keys, () => []).add(i);
    }
    return grouped;
  }

  TransactionFilter _selectedFilter = TransactionFilter.semua;

  void _onFilterTap(TransactionFilter filter){
    if(filter == _selectedFilter) return;
    setState(() {
      _selectedFilter = filter;
      _futureListTransactions = _fetchTransactions();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 340,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: AppColors.balanceBlue
                  ),
                ),
              ),
              SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: FutureBuilder<List<TransactionModel>>(
                        future: _futureListTransactions,
                        builder: (context, snapshot) {
                          var transactionsData = snapshot.data ?? <TransactionModel>[];
                          final isLoading = snapshot.connectionState == ConnectionState.waiting;
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Riwayat Transaksi",
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700
                                  ) ,
                                ),
                                SizedBox(height: 50,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: TransactionFilter.values
                                      .map(_filterBuilder)
                                      .toList(),
                                ),
                                const SizedBox(height: 20),
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
                                      if (isLoading)
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      else if (transactionsData.isEmpty)
                                        _buildEmptyState()
                                      else
                                        ..._groupedByDate(transactionsData)
                                            .entries
                                            .map((entry) => _buildDateGroup(entry.key, entry.value)),
                                    ],
                                  ),
                                ),
                              ],
                          );
                        }
                    )
                  )
              ),
            ],
          ),
        )
    );
  }


  Widget _filterBuilder(TransactionFilter filter){
    final isActive = _selectedFilter == filter;
    return InkWell(
      onTap: (){
        _onFilterTap(filter);
      },
      borderRadius: BorderRadius.circular(16),
      child:
      Container(
        padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10
        ),
        decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            border: Border.all(
                color: Colors.white
            ),
            borderRadius: BorderRadius.circular(16)
        ),
        child: Text(
          filter.label,
          style:
          TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.balanceBlue : Colors.white
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(){
    final message = _selectedFilter == TransactionFilter.semua
        ? "Belum ada transaksi yang tercatat."
        : "Tidak ada transaksi ${_selectedFilter.label.toLowerCase()}.";

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            SizedBox(height: 100,),
            Icon(Icons.no_sim_rounded, color: AppColors.textSecondary, size: 100,),
            SizedBox(height: 24,),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  fontSize: 16
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDateGroup(DateTime date, List<TransactionModel> items){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              _formatGroupLabel(date),
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.textPrimary
              ),
            ),
        ),
        ...items.map(_buildTransactionItem)
      ],
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final isIncome = transaction.type == 'pemasukan';
    final notes = transaction.notes?.trim() ?? '';
    final time = '${transaction.createdAt.hour.toString().padLeft(2, '0')} : '
        '${transaction.createdAt.minute.toString().padLeft(2, '0')}';
    final subtitle = notes.isEmpty ? time : '$time · $notes';

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

