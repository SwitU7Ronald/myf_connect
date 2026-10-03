import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myf_connect/core/models/camp.dart';

// ignore: subtype_of_sealed_class
class FakeDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic> _data;

  FakeDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Camp Model', () {
    test('supports value equality', () {
      final camp1 = Camp(
        id: '1',
        title: 'Title',
        description: 'Desc',
        place: 'Place',
        date: DateTime(2023, 1, 1),
      );
      final camp2 = Camp(
        id: '1',
        title: 'Title',
        description: 'Desc',
        place: 'Place',
        date: DateTime(2023, 1, 1),
      );
      expect(camp1, equals(camp2));
    });

    test('fromFirestore creates correct Camp from Timestamp', () {
      final mockSnapshot = FakeDocumentSnapshot('1', {
        'title': 'Title',
        'description': 'Desc',
        'place': 'Place',
        'date': Timestamp.fromDate(DateTime(2023, 1, 1)),
      });

      final camp = Camp.fromFirestore(mockSnapshot);

      expect(camp.id, '1');
      expect(camp.title, 'Title');
      expect(camp.description, 'Desc');
      expect(camp.place, 'Place');
      expect(camp.date, DateTime(2023, 1, 1));
    });

    test('fromFirestore creates correct Camp from String date', () {
      final mockSnapshot = FakeDocumentSnapshot('1', {
        'title': 'Title',
        'description': 'Desc',
        'place': 'Place',
        'date': '2023-01-01T00:00:00.000',
      });

      final camp = Camp.fromFirestore(mockSnapshot);

      expect(camp.id, '1');
      expect(camp.title, 'Title');
      expect(camp.description, 'Desc');
      expect(camp.place, 'Place');
      expect(camp.date, DateTime(2023, 1, 1));
    });

    test(
      'fromFirestore creates Camp with default values when data is missing',
      () {
        final mockSnapshot = FakeDocumentSnapshot('1', {});

        final camp = Camp.fromFirestore(mockSnapshot);

        expect(camp.title, 'Unnamed Camp');
        expect(camp.place, '');
        expect(camp.description, '');
        expect(camp.date, isNull);
      },
    );
  });
}
