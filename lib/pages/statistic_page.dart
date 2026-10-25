import "package:flutter/material.dart";
import "package:fl_chart/fl_chart.dart";
import "package:sakuku/models/transaction_model.dart";
import "package:sakuku/widgets/curve_background.dart";
import "package:sakuku/assets/color_apps.dart";
import "package:sakuku/repositories/transaction_repository.dart";

enum TransactionFilter {
  pemasukan('Pemasukan', 'pemasukan'),
  pengeluaran('Pengeluaran', 'pengeluaran');

  const TransactionFilter(this.label, this.dbValue);
  final String label;
  final String? dbValue;
}
enum PeriodFilter {
  minggu('Minggu'),
  bulan("Bulan"),
  tahun("Tahun");

  const PeriodFilter(this.label);
  final String label;
}

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  late Future<List<TransactionModel>> _futureListTransactions;
  int _touchedIndex = -1;
  final List<Color> _chartColors = const [
    Color(0xFF4C6EF5),
    Color(0xFFFA5252),
    Color(0xFF40C057),
    Color(0xFFFAB005),
    Color(0xFF9775FA),
    Color(0xFF15AABF),
    Color(0xFFFF922B),
  ];

  // Warna disimpan per nama kategori supaya kategori yang sama tidak berganti
  // warna ketika periode/jenis transaksi diganti.
  final Map<String, Color> _categoryColors = <String, Color>{};
  int _nextCategoryColor = 0;

  Color _colorForCategory(String category) {
    final cached = _categoryColors[category];
    if (cached != null) return cached;

    final color = _chartColors[_nextCategoryColor % _chartColors.length];
    _nextCategoryColor++;
    _categoryColors[category] = color;
    return color;
  }

  @override
  void initState(){
    super.initState();
    _futureListTransactions = _fetchTransactions();
    TransactionRepository.revision.addListener(_reload);
  }

  @override
  void dispose(){
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
    final range = _currentRange();
    return TransactionRepository.getListTransactions(
        type: _selectedType.dbValue,
        start: range.start,
        end: range.end
    );
  }

  Map<String, double> _groupByCategory(List<TransactionModel> transactions){
    final dataTransactions = [...transactions];
    final Map<String, double> result = {};

    for(final transaksi in dataTransactions){
      result[transaksi.category] = (result[transaksi.category] ?? 0) + transaksi.amount.toDouble();
    }
    return result;
  }

  DateTimeRange _weekRange(DateTime now){
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: today.weekday - 1));
    final end = start.add(const Duration(days: 7));
    return DateTimeRange(start: start, end: end);
  }

  DateTimeRange _monthRange(DateTime now){
    return (
        DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end : DateTime(now.year, now.month + 1, 1)
        )
    );
  }

  DateTimeRange _yearRange(DateTime now){
    return (
        DateTimeRange(
            start: DateTime(now.year, 1, 1),
            end : DateTime(now.year + 1, 1, 1)
        )
    );
  }

  TransactionFilter _selectedType = TransactionFilter.pengeluaran;
  PeriodFilter _selectedPeriod = PeriodFilter.bulan;

  DateTimeRange _currentRange(){
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case PeriodFilter.minggu:
        return _weekRange(now);
      case PeriodFilter.bulan:
        return _monthRange(now);
      case PeriodFilter.tahun:
        return _yearRange(now);
    }
  }

  void _onPeriodTap(PeriodFilter period){
    if(period == _selectedPeriod)return;
    setState(() {
      _selectedPeriod = period;
      _touchedIndex = -1;
      _futureListTransactions = _fetchTransactions();
    });
  }
  void _onFilterTap(TransactionFilter filter){
    if(filter == _selectedType) return;
    setState(() {
      _selectedType = filter;
      _touchedIndex = -1;
      _futureListTransactions = _fetchTransactions();
    });
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

  List<PieChartSectionData> _buildSections(List<MapEntry<String, double>> entries){
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);
    if(total <= 0) return [];

    return List.generate(entries.length, (i){
      final isTapped = i == _touchedIndex;
      final percent = entries[i].value / total * 100;

      return PieChartSectionData(
        value: entries[i].value,
        color: _colorForCategory(entries[i].key),
        radius: isTapped ? 70 : 60,
        title: "${percent.toStringAsFixed(0)}%",
        titleStyle: TextStyle(
          fontSize: 12,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w500,
          color: Colors.white
        )
      );
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Statistik",
                          style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w700
                          ) ,
                        ),
                        SizedBox(height: 10,),
                        Row(
                          spacing: 12,
                          children: PeriodFilter.values
                              .map((period) => Expanded(child: _filterBuilderPeriod(period)))
                              .toList(),
                        ),
                        SizedBox(height: 30,),
                        Text(
                          "Jenis Transaksi",
                          style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600
                          ) ,
                        ),
                        SizedBox(height: 12,),
                        Row(
                          spacing: 12,
                          children: TransactionFilter.values
                              .map((filter) => Expanded(child: _filterBuilder(filter)))
                              .toList(),
                        ),
                        SizedBox(height: 25,),
                        _buildTotalText(),
                        SizedBox(height: 15,),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildChartCard(),
                        )
                      ]
                    ),
                  )
              )
            ],
          ),
        )
    );
  }


  Widget _filterBuilder(TransactionFilter filter){
    final isActive = _selectedType == filter;
    return InkWell(
      onTap: (){
        _onFilterTap(filter);
      },
      borderRadius: BorderRadius.circular(16),
      child:
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
            horizontal: 12,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
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
  Widget _filterBuilderPeriod(PeriodFilter period){
    final isActive = _selectedPeriod == period;
    return InkWell(
      onTap: (){
        _onPeriodTap(period);
      },
      borderRadius: BorderRadius.circular(16),
      child:
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
            horizontal: 12,
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
          period.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
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
  Widget _buildChartCard(){
    return FutureBuilder(
        future: _futureListTransactions,
        builder: (context, snapshots){
          if(snapshots.connectionState == ConnectionState.waiting){
            return SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator(),),
            );
          }

        //   Snapshot error
          if(snapshots.hasError){
            debugPrint('StatisticPage chart error: ${snapshots.error}');
            debugPrintStack(stackTrace: snapshots.stackTrace);
            return const SizedBox(
              height: 250,
              child: Center(child: Text("Gagal memuat data statistik")),
            );
          }

          final transactions = snapshots.data ?? [];
          if (transactions.isEmpty) {
            return const SizedBox(
              height: 250,
              child: Center(child: Text("Belum ada transaksi")),
            );
          }

          final grouped = _groupByCategory(transactions);
          // Urutkan dari nominal terbesar agar urutan chart dan legend konsisten.
          final entries = grouped.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return Column(
            children: [
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: _buildSections(entries),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response){
                        int? next;
                        if (event.isInterestedForInteractions && response?.touchedSection != null) {
                          next = response!.touchedSection!.touchedSectionIndex;
                        }
                        if (next == _touchedIndex) return;
                        setState(() => _touchedIndex = next ?? -1);
                      }
                    )
                  )
                ),
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Kategori",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: List.generate(entries.length, (i) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _colorForCategory(entries[i].key),
                          shape: BoxShape.circle
                        ),
                      ),
                      const SizedBox(width: 6,),
                      Text(
                        entries[i].key,
                        style: const TextStyle(fontFamily: "Poppins", fontSize: 12),
                      )
                    ],
                  );
                }),
              ),
            ],
          );
        }
    );
  }
  Widget _buildTotalText(){
    return FutureBuilder(
        future: _futureListTransactions,
        builder: (context, snapshots){
          String text;

          if(snapshots.connectionState == ConnectionState.waiting){
            text = "...";
          }else if(snapshots.hasError){
            debugPrint('StatisticPage fetch error: ${snapshots.error}');
            debugPrintStack(stackTrace: snapshots.stackTrace);
            text = 'Gagal memuat data';
          }else{
            final transactionsData = snapshots.data ?? [];
            final total = transactionsData.fold<double>(0, (sum, item) => sum + item.amount);
            text = _formatRupiah(total);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total ${_selectedType.label}",   // Total Pengeluaran / Total Pemasukan
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              )
            ],
          );
        }
    );
  }
}

