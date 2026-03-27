import 'package:cloud_firestore/cloud_firestore.dart';

class CreditCardModel {
  final String id;
  final String bankName;
  final String cardName;
  final String holderName;
  final String brand;
  final String lastFourDigits;
  final double creditLimit;
  final int statementDay;
  final int dueDay;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreditCardModel({
    required this.id,
    required this.bankName,
    required this.cardName,
    required this.holderName,
    required this.brand,
    required this.lastFourDigits,
    required this.creditLimit,
    required this.statementDay,
    required this.dueDay,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreditCardModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return CreditCardModel(
      id: id,
      bankName: map['bankName'] as String? ?? '',
      cardName: map['cardName'] as String? ?? '',
      holderName: map['holderName'] as String? ?? '',
      brand: map['brand'] as String? ?? 'Visa',
      lastFourDigits: map['lastFourDigits'] as String? ?? '',
      creditLimit: (map['creditLimit'] as num?)?.toDouble() ?? 0,
      statementDay: map['statementDay'] as int? ?? 1,
      dueDay: map['dueDay'] as int? ?? 1,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'cardName': cardName,
      'holderName': holderName,
      'brand': brand,
      'lastFourDigits': lastFourDigits,
      'creditLimit': creditLimit,
      'statementDay': statementDay,
      'dueDay': dueDay,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CreditCardModel copyWith({
    String? id,
    String? bankName,
    String? cardName,
    String? holderName,
    String? brand,
    String? lastFourDigits,
    double? creditLimit,
    int? statementDay,
    int? dueDay,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditCardModel(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      cardName: cardName ?? this.cardName,
      holderName: holderName ?? this.holderName,
      brand: brand ?? this.brand,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      creditLimit: creditLimit ?? this.creditLimit,
      statementDay: statementDay ?? this.statementDay,
      dueDay: dueDay ?? this.dueDay,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  DateTime nextStatementDate({DateTime? from}) {
    final now = from ?? DateTime.now();
    final thisMonthDate = _safeDate(now.year, now.month, statementDay);

    if (!_isDatePassed(thisMonthDate, now)) {
      return thisMonthDate;
    }

    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextYear = now.month == 12 ? now.year + 1 : now.year;

    return _safeDate(nextYear, nextMonth, statementDay);
  }

  DateTime nextDueDate({DateTime? from}) {
    final now = from ?? DateTime.now();
    final thisMonthDate = _safeDate(now.year, now.month, dueDay);

    if (!_isDatePassed(thisMonthDate, now)) {
      return thisMonthDate;
    }

    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextYear = now.month == 12 ? now.year + 1 : now.year;

    return _safeDate(nextYear, nextMonth, dueDay);
  }

  int daysUntilStatement({DateTime? from}) {
    final now = from ?? DateTime.now();
    return nextStatementDate(from: now)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  int daysUntilDue({DateTime? from}) {
    final now = from ?? DateTime.now();
    return nextDueDate(from: now)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  bool get shouldWarnStatementSoon => daysUntilStatement() <= 5;
  bool get shouldWarnDueSoon => daysUntilDue() <= 7;

  static bool _isDatePassed(DateTime target, DateTime now) {
    final nowWithoutTime = DateTime(now.year, now.month, now.day);
    return target.isBefore(nowWithoutTime);
  }

  static DateTime _safeDate(int year, int month, int day) {
    final maxDay = DateTime(year, month + 1, 0).day;
    final safeDay = day > maxDay ? maxDay : day;
    return DateTime(year, month, safeDay);
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }
}