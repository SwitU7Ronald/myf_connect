import 'package:cloud_firestore/cloud_firestore.dart';

class CampEvent {
  final String id;
  final DateTime dateTime;
  final String title;
  final String description;
  final String? venue;
  final double avgRating;
  final int numRatings;

  CampEvent({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.description,
    this.venue,
    this.avgRating = 0.0,
    this.numRatings = 0,
  });

  factory CampEvent.fromMap(String id, Map<String, dynamic> data) {
    final raw = data['dateTime'];
    final dt = raw is Timestamp ? raw.toDate() : DateTime.parse(raw as String);
    return CampEvent(
      id: id,
      dateTime: dt,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      venue: data['venue'],
      avgRating: (data['avgRating'] ?? 0.0).toDouble(),
      numRatings: data['numRatings'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTime': Timestamp.fromDate(dateTime),
      'title': title,
      'description': description,
      if (venue != null) 'venue': venue,
      'avgRating': avgRating,
      'numRatings': numRatings,
    };
  }

  String get dayOfWeek =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dateTime.weekday - 1];
}

class MyfEvent {
  final String id;
  final DateTime dateTime;
  final String title;
  final String description;
  final String? venue;
  final double avgRating;
  final int numRatings;

  MyfEvent({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.description,
    this.venue,
    this.avgRating = 0.0,
    this.numRatings = 0,
  });

  factory MyfEvent.fromMap(String id, Map<String, dynamic> data) {
    final raw = data['dateTime'];
    final dt = raw is Timestamp ? raw.toDate() : DateTime.parse(raw as String);
    return MyfEvent(
      id: id,
      dateTime: dt,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      venue: data['venue'],
      avgRating: (data['avgRating'] ?? 0.0).toDouble(),
      numRatings: data['numRatings'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTime': Timestamp.fromDate(dateTime),
      'title': title,
      'description': description,
      if (venue != null) 'venue': venue,
      'avgRating': avgRating,
      'numRatings': numRatings,
    };
  }

  String get dayOfWeek =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dateTime.weekday - 1];
}
