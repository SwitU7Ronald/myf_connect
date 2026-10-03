import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myf_connect/core/models/event.dart';

void main() {
  group('AppEvent Model', () {
    final dateTime = DateTime(2023, 1, 1, 12, 0); // Sunday

    test('supports value equality', () {
      final event1 = AppEvent(
        id: '1',
        dateTime: dateTime,
        title: 'Title',
        description: 'Desc',
        venue: 'Venue',
        avgRating: 4.5,
        numRatings: 10,
      );
      final event2 = AppEvent(
        id: '1',
        dateTime: dateTime,
        title: 'Title',
        description: 'Desc',
        venue: 'Venue',
        avgRating: 4.5,
        numRatings: 10,
      );
      expect(event1, equals(event2));
    });

    test('fromMap creates correct AppEvent from Timestamp', () {
      final map = {
        'dateTime': Timestamp.fromDate(dateTime),
        'title': 'Title',
        'description': 'Desc',
        'venue': 'Venue',
        'avgRating': 4.5,
        'numRatings': 10,
      };

      final event = AppEvent.fromMap('1', map);

      expect(event.id, '1');
      expect(event.dateTime, dateTime);
      expect(event.title, 'Title');
      expect(event.description, 'Desc');
      expect(event.venue, 'Venue');
      expect(event.avgRating, 4.5);
      expect(event.numRatings, 10);
    });

    test('fromMap creates correct AppEvent from String date', () {
      final map = {
        'dateTime': dateTime.toIso8601String(),
        'title': 'Title',
        'description': 'Desc',
      };

      final event = AppEvent.fromMap('1', map);

      expect(event.id, '1');
      expect(event.dateTime, dateTime);
      expect(event.title, 'Title');
      expect(event.description, 'Desc');
      expect(event.venue, isNull);
      expect(event.avgRating, 0.0);
      expect(event.numRatings, 0);
    });

    test('toMap converts AppEvent to map', () {
      final event = AppEvent(
        id: '1',
        dateTime: dateTime,
        title: 'Title',
        description: 'Desc',
        venue: 'Venue',
        avgRating: 4.5,
        numRatings: 10,
      );

      final map = event.toMap();

      expect(map['dateTime'], isA<Timestamp>());
      expect((map['dateTime'] as Timestamp).toDate(), dateTime);
      expect(map['title'], 'Title');
      expect(map['description'], 'Desc');
      expect(map['venue'], 'Venue');
      expect(map['avgRating'], 4.5);
      expect(map['numRatings'], 10);
    });

    test('toMap handles null venue correctly', () {
      final event = AppEvent(
        id: '1',
        dateTime: dateTime,
        title: 'Title',
        description: 'Desc',
      );

      final map = event.toMap();

      expect(map.containsKey('venue'), isFalse);
    });

    test('dayOfWeek returns correct abbreviation', () {
      final sunEvent = AppEvent(
        id: '1',
        dateTime: DateTime(2023, 1, 1),
        title: '',
        description: '',
      ); // Sun
      final monEvent = AppEvent(
        id: '1',
        dateTime: DateTime(2023, 1, 2),
        title: '',
        description: '',
      ); // Mon
      final tueEvent = AppEvent(
        id: '1',
        dateTime: DateTime(2023, 1, 3),
        title: '',
        description: '',
      ); // Tue

      expect(sunEvent.dayOfWeek, 'Sun');
      expect(monEvent.dayOfWeek, 'Mon');
      expect(tueEvent.dayOfWeek, 'Tue');
    });
  });
}
