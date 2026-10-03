import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myf_connect/core/models/myf.dart';

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
  group('Myf Model', () {
    test('supports value equality', () {
      final myf1 = Myf(id: '1', title: 'Title', description: 'Desc');
      final myf2 = Myf(id: '1', title: 'Title', description: 'Desc');
      expect(myf1, equals(myf2));
    });

    test('fromFirestore creates correct Myf', () {
      final mockSnapshot = FakeDocumentSnapshot('1', {
        'title': 'Title',
        'description': 'Desc',
      });

      final myf = Myf.fromFirestore(mockSnapshot);

      expect(myf.id, '1');
      expect(myf.title, 'Title');
      expect(myf.description, 'Desc');
    });

    test(
      'fromFirestore creates Myf with default values when data is missing',
      () {
        final mockSnapshot = FakeDocumentSnapshot('1', {});

        final myf = Myf.fromFirestore(mockSnapshot);

        expect(myf.title, 'Untitled MYF');
        expect(myf.description, '');
      },
    );
  });
}
