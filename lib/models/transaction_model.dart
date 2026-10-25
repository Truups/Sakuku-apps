
class TransactionModel {
  final int? id;
  final String type;
  final String category;
  final double amount;
  final String? notes;
  final DateTime createdAt;

  //Constructor
  TransactionModel({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    this.notes,
    required this.createdAt
  });

  //Data Mapping
  Map<String, dynamic>toMap(){
    return{
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'notes': notes,
      'created_at': createdAt.toIso8601String()
    };
  }

  factory TransactionModel.fromMap(Map<String, Object?>map){
    return TransactionModel(
        id: map['id'] as int?,
        type: map['type'] as String,
        category: map['category'] as String? ?? '-',
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        notes: map['notes'] as String?,
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??  DateTime.fromMillisecondsSinceEpoch(0)
    );
  }
}