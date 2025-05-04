class Shift {
  final int? id;
  final String? shiftName;
  final String? startTime;
  final String? endTime;
  final int? openingCash;
  final int? closingCash;
  final int isActive;

  Shift({
    this.id,
    this.shiftName,
    this.startTime,
    this.endTime,
    this.openingCash,
    this.closingCash,
    this.isActive = 0,
  });

  factory Shift.fromMap(Map<String, dynamic> map) => Shift(
    id: map['id'],
    shiftName: map['shift_name'],
    startTime: map['start_time'],
    endTime: map['end_time'],
    openingCash: map['opening_cash'],
    closingCash: map['closing_cash'],
    isActive: map['is_active'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'shift_name': shiftName,
    'start_time': startTime,
    'end_time': endTime,
    'opening_cash': openingCash,
    'closing_cash': closingCash,
    'is_active': isActive,
  };
}
