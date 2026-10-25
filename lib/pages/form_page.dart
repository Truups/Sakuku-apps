import 'package:flutter/material.dart';
import 'package:sakuku/assets/color_apps.dart';
import 'package:sakuku/models/transaction_model.dart';
import 'package:sakuku/repositories/transaction_repository.dart';
import 'package:sakuku/widgets/form_field.dart';
import 'package:sakuku/widgets/curve_background.dart';


class TransactionFormPage extends StatefulWidget {
  final String type;
  const TransactionFormPage({
    super.key,
    required this.type
  });

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? category;
  double amount = 0;
  String notes = "";
  DateTime selectedDate = DateTime.now();
  bool _isSaving = false;
  double parseAmount(String value){
    return double.tryParse(value) ?? 0.0;
  }

  // Form Validate
  Future<void> _submit() async{
    if(!_formKey.currentState!.validate()) return;
    if(category == null || _isSaving) return;
    setState(() => _isSaving = true);

    //Model dari isian form
    final transaction = TransactionModel(
        type: widget.type,
        category: category!,
        amount: amount,
        notes: notes.trim().isEmpty ? null : notes.trim(),
        createdAt: selectedDate
    );

    //Simpan ke sqlite db
    try{
      await TransactionRepository.addTransactions(transaction);
      //Feedback sukses menyimpan
      await showModalBottomSheet(
        context: context,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.income,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Transaksi berhasil dicatat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.balanceBlue,
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Selesai'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if(!mounted) return;
      Navigator.of(context).pop(true);
    }catch(error){
      if(!mounted) return;
      await showModalBottomSheet(
        context: context,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.income,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Transaksi gagal dicatat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.balanceBlue,
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Selesai'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally{
      if(mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String labelType = widget.type == 'pemasukan' ? "Pemasukan" : "Pengeluaran";
    return Scaffold(
      body: Stack(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  labelType,
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
                    Form(
                        key: _formKey,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child:
                          TransactionFormField(
                            type: widget.type,
                            onAmountChanged: (value){
                              amount = parseAmount(value);
                            },
                            onCategoryChanged: (value) {
                              category = value;
                            },
                            onNotesChanged: (value){
                              notes = value;
                            },
                            onDateChanged: (value){
                              selectedDate = value;
                            },
                          )

                        ),
                    ),
                    const SizedBox(height: 50,),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.balanceBlue
                        ),
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Submit',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      )
                  ],
                ),
              ),
            ),
        ],
      )
    );
  }
}
