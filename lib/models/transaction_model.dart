import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String type;
  final String title;
  final String category;
  final String classification;
  final double amount;
  final DateTime date;
  final String notes;
  final bool isRecurring;
  final String recurrence;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.category,
    required this.classification,
    required this.amount,
    required this.date,
    required this.notes,
    required this.isRecurring,
    required this.recurrence,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  factory TransactionModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return TransactionModel(
      id: id,
      type: map['type'] as String? ?? 'expense',
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      classification: map['classification'] as String? ?? 'variable',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      date: _parseDate(map['date']),
      notes: map['notes'] as String? ?? '',
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurrence: map['recurrence'] as String? ?? 'none',
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'category': category,
      'classification': classification,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'isRecurring': isRecurring,
      'recurrence': recurrence,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? type,
    String? title,
    String? category,
    String? classification,
    double? amount,
    DateTime? date,
    String? notes,
    bool? isRecurring,
    String? recurrence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      category: category ?? this.category,
      classification: classification ?? this.classification,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrence: recurrence ?? this.recurrence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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