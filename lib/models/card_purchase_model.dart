import 'package:cloud_firestore/cloud_firestore.dart';

class CardPurchaseModel {
  final String id;
  final String title;
  final double amount;
  final DateTime purchaseDate;
  final int installments;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CardPurchaseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.purchaseDate,
    required this.installments,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CardPurchaseModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return CardPurchaseModel(
      id: id,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      purchaseDate: _parseDate(map['purchaseDate']),
      installments: map['installments'] as int? ?? 1,
      notes: map['notes'] as String? ?? '',
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'installments': installments,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CardPurchaseModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? purchaseDate,
    int? installments,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CardPurchaseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      installments: installments ?? this.installments,
      notes: notes ?? this.notes,
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