class AlertItemModel {
  final String id;
  final String title;
  final String message;
  final String level;

  const AlertItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
  });

  factory AlertItemModel.fromMap(Map<String, dynamic> map) {
    return AlertItemModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      level: map['level'] as String? ?? 'info',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'level': level,
    };
  }
}