import 'package:cloud_firestore/cloud_firestore.dart';

class AlertItemModel {
  final String id;
  final String title;
  final String message;

  /// 'info' | 'warning' | 'danger'
  final String level;

  /// 'budget' | 'card_statement' | 'card_due' | 'general'
  final String type;

  final String? cardId;
  final DateTime date;

  const AlertItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.type,
    required this.date,
    this.cardId,
  });

  factory AlertItemModel.fromMap(Map<String, dynamic> map) {
    return AlertItemModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      level: map['level'] as String? ?? 'info',
      type: map['type'] as String? ?? 'general',
      cardId: map['cardId'] as String?,
      date: _parseDate(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'level': level,
      'type': type,
      'cardId': cardId,
      'date': Timestamp.fromDate(date),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}