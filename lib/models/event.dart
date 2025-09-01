import 'package:cloud_firestore/cloud_firestore.dart';

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
    final raw = data['dateTime'];
    final dt = raw is Timestamp ? raw.toDate() : DateTime.parse(raw as String);

    return CampEvent(
      id: id,
      dateTime: dt,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTime': Timestamp.fromDate(dateTime),  // Use Timestamp
      'title': title,
      'description': description,
    };
  }
}
