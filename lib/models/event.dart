import 'package:cloud_firestore/cloud_firestore.dart';

class CampEvent {
  final String id;
  final DateTime dateTime;
  final String title;
  final String description;
  final String? venue;

  CampEvent({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.description,
    this.venue,
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
      venue: data['venue'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTime': Timestamp.fromDate(dateTime),
      'title': title,
      'description': description,
      if (venue != null) 'venue': venue,
    };
  }
}
