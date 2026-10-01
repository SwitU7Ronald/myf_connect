import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A unified event model used for both Camp events and MYF events.
///
/// Eliminates the duplication of [CampEvent] and [MyfEvent] which were
/// structurally identical. The [isCamp] flag indicates the parent context.
class AppEvent extends Equatable {
  final String id;
  final DateTime dateTime;
  final String title;
  final String description;
  final String? venue;
  final double avgRating;
  final int numRatings;

  const AppEvent({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.description,
    this.venue,
    this.avgRating = 0.0,
    this.numRatings = 0,
  });

  factory AppEvent.fromMap(String id, Map<String, dynamic> data) {
    final raw = data['dateTime'];
    final dt = raw is Timestamp ? raw.toDate() : DateTime.parse(raw as String);
    return AppEvent(
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

  /// Short day-of-week abbreviation derived from [dateTime].
  String get dayOfWeek =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dateTime.weekday - 1];

  @override
  List<Object?> get props =>
      [id, dateTime, title, description, venue, avgRating, numRatings];
}
