class SalesOrder {
  final int? id;
  final String? orderNumber;
  final String? createdAt;
  final String? updatedAt;
  final String? status;
  final int? shiftId;
  final double? total;
  final double? totalTax; // Snapshot total pajak
  final double? totalDiscount; // Snapshot total diskon
  final int? customerId; // 🔄 Revisi: gunakan ID, bukan nama
  final String? ticketName;
  final String? comment;

  SalesOrder({
    this.id,
    this.orderNumber,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.shiftId,
    this.total,
    this.totalTax,
    this.totalDiscount,
    this.customerId,
    this.ticketName,
    this.comment,
  });

  factory SalesOrder.fromMap(Map<String, dynamic> map) {
    return SalesOrder(
      id: map['id'] as int?,
      orderNumber: map['order_number'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      status: map['status'] as String?,
      shiftId: map['shift_id'] as int?,
      total: map['total'] != null ? (map['total'] as num).toDouble() : 0.0,
      totalTax:
          map['total_tax'] != null ? (map['total_tax'] as num).toDouble() : 0.0,
      totalDiscount:
          map['total_discount'] != null
              ? (map['total_discount'] as num).toDouble()
              : 0.0,
      customerId: map['customer_id'] as int?, // 🔄 gunakan ID
      ticketName: map['ticket_name'] as String?,
      comment: map['comment'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'order_number': orderNumber,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'status': status,
      'shift_id': shiftId,
      'total': total,
      'total_tax': totalTax,
      'total_discount': totalDiscount,
      'customer_id': customerId, // 🔄 simpan ID
      'ticket_name': ticketName,
      'comment': comment,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }
}
