class CashTransaction {
  final int? id;
  final int shiftId;
  final double amount;
  final String type;
  final String? comment;
  final String? createdAt;

  CashTransaction({
    this.id,
    required this.shiftId,
    required this.amount,
    required this.type,
    this.comment,
    this.createdAt,
  });

  factory CashTransaction.fromMap(Map<String, dynamic> map) => CashTransaction(
    id: map['id'],
    shiftId: map['shift_id'],
    amount: (map['amount'] as num).toDouble(),
    type: map['type'],
    comment: map['comment'],
    createdAt: map['created_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'shift_id': shiftId,
    'amount': amount,
    'type': type,
    'comment': comment,
    'created_at': createdAt,
  };
}
