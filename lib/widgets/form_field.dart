import 'package:flutter/material.dart';
import 'package:sakuku/assets/color_apps.dart';

class TransactionFormField extends StatefulWidget {
  final String type;
  final ValueChanged<String>? onAmountChanged;
  final ValueChanged<String>? onCategoryChanged;
  final ValueChanged<String>? onNotesChanged;
  final ValueChanged<DateTime>? onDateChanged;

  const TransactionFormField({
    super.key,
    required this.type,
    this.onAmountChanged,
    this.onCategoryChanged,
    this.onNotesChanged,
    this.onDateChanged
  });

  @override
  State<TransactionFormField> createState() => _TransactionFormFieldState();
}

class _TransactionFormFieldState extends State<TransactionFormField> {
  DateTime selectedDate = DateTime.now();
  final GlobalKey<FormFieldState<String>> categoryFieldKey = GlobalKey<FormFieldState<String>>();

  final TextEditingController amountController =
  TextEditingController();

  final TextEditingController notesController =
  TextEditingController();

  final List<String> expenseCategories = [
    'Makanan & Minuman',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  final List<String> incomeCategories = [
    'Gaji',
    'Bonus',
    'Investasi',
    'Freelance',
    'Hadiah',
    'Bisnis',
    'Lainnya',
  ];

  List<String> get categories {
    return widget.type == 'pengeluaran'
        ? expenseCategories
        : incomeCategories;
  }

  @override
  void dispose() {
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> showCategorySheet() async {
    final String? category = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Pilih Kategori ${widget.type}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final category = categories[index];

                      return ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                          const Color(0xFFEAF1FF),
                          child: Icon(
                            widget.type ==
                                'pengeluaran'
                                ? Icons.shopping_bag_outlined
                                : Icons.account_balance_wallet_outlined,
                            color: const Color(0xFF4263EB),
                          ),
                        ),
                        title: Text(category),
                        trailing: categoryFieldKey.currentState?.value == category
                            ? const Icon( Icons.check_circle,  color: Color(0xFF4263EB))
                            : const Icon(Icons.chevron_right,),
                        onTap: () {
                          Navigator.pop(context, category);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    if (category != null) {
      final FormFieldState<String>? categoryField = categoryFieldKey.currentState;
      categoryField?.didChange(category);
      if(categoryField?.hasError ?? false){
        categoryField!.validate();
      }
      widget.onCategoryChanged?.call(category);
    }
  }

  Future<void> selectDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted) return;

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
      widget.onDateChanged?.call(date);
    }
  }

  String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'Mei', 'Jun', 'Jul', 'Agu',
      'Sep', 'Okt', 'Nov', 'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget buildField({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String label,
    required Widget content,
    VoidCallback? onTap,
    bool showArrow = false,
    double minHeight = 68,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFDCE8FA),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7185A5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    content,
                  ],
                ),
              ),

              if (showArrow)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.type == 'pengeluaran';

    return Column(
      children: [
        // Kategori
        FormField<String>(
          key: categoryFieldKey,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Kategori harus dipilih dulu.';
            }
            return null;
          },
          builder: (FormFieldState<String> state) {
            return buildField(
                  icon: isExpense
                      ? Icons.card_giftcard
                      : Icons.account_balance_wallet,
                  iconColor: isExpense
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF10B981),
                  iconBackground: isExpense
                      ? const Color(0xFFFFE5E7)
                      : const Color(0xFFDDF8EC),
                  label: 'Kategori',
                  onTap: showCategorySheet,
                  showArrow: true,
                  content: InputDecorator(
                    isEmpty: state.value == null,
                    decoration: InputDecoration(
                      hintText: 'Pilih kategori',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      errorText: state.errorText,
                      errorStyle: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        height: 1.2,
                      ),
                      errorMaxLines: 2,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    child: Text(
                      state.value ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF23385B),
                      ),
                    ),
                  ),
            );
          },
        ),

        const SizedBox(height: 14),

        // Jumlah
        buildField(
          icon: Icons.account_balance_wallet,
          iconColor: const Color(0xFF10B981),
          iconBackground: const Color(0xFFDDF8EC),
          label: 'Jumlah',
          content: TextFormField(
            controller: amountController,
            keyboardType:
            const TextInputType.numberWithOptions(
              decimal: true,
            ),
            validator: (value){
              if(value == null || value.isEmpty){
                return "Jumlah harus diisi dulu.";
              }
              final amount = double.tryParse(value.trim());

              if(amount == null){
                return "Value harus berupa angka";
              }

              if(amount <= 0){
                return "Jumlah harus lebih besar dari 0";
              }

              return null;
            },
            onChanged: widget.onAmountChanged,
            decoration: const InputDecoration(
              hintText: 'Rp 0',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Tanggal
        buildField(
          icon: Icons.calendar_month,
          iconColor: const Color(0xFF4263EB),
          iconBackground: const Color(0xFFE4E9FF),
          label: 'Tanggal',
          content: Text(
            formatDate(selectedDate),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF23385B),
            ),
          ),
          onTap: selectDate,
          showArrow: true,
        ),

        const SizedBox(height: 14),

        // Catatan
        buildField(
          icon: Icons.edit_outlined,
          iconColor: const Color(0xFF23385B),
          iconBackground: const Color(0xFFEDF2FA),
          label: 'Catatan (Opsional)',
          minHeight: 70,
          content: TextField(
            controller: notesController,
            maxLines: 2,
            onChanged: widget.onNotesChanged,
            decoration: const InputDecoration(
              hintText: 'Tambahkan catatan',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
