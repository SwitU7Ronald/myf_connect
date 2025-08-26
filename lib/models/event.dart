class CampEvent {
  final String id;
  final DateTime dateTime;
  final String title;
  final String description;

  CampEvent({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.description,
  });

  String get dayOfWeek =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dateTime.weekday - 1];

  factory CampEvent.fromMap(String id, Map<String, dynamic> data) {
    return CampEvent(
      id: id,
      dateTime: DateTime.parse(data['dateTime']),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'title': title,
      'description': description,
    };
  }
}
