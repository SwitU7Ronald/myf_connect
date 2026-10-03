import 'package:flutter_test/flutter_test.dart';
import 'package:myf_connect/core/models/app_user.dart';

void main() {
  group('AppUser Model', () {
    test('supports value equality', () {
      final user1 = AppUser(
        uid: '1',
        email: 'test@test.com',
        firstName: 'First',
        lastName: 'Last',
        phone: '12345',
        church: 'Myf',
        district: 'District',
        gender: 'Male',
        permissions: const ['admin'],
      );
      final user2 = AppUser(
        uid: '1',
        email: 'test@test.com',
        firstName: 'First',
        lastName: 'Last',
        phone: '12345',
        church: 'Myf',
        district: 'District',
        gender: 'Male',
        permissions: const ['admin'],
      );
      expect(user1, equals(user2));
    });

    test('fromMap creates correct AppUser', () {
      final map = {
        'email': 'test@test.com',
        'firstName': 'First',
        'lastName': 'Last',
        'phone': '12345',
        'church': 'Myf',
        'district': 'District',
        'gender': 'Male',
        'permissions': ['admin'],
      };

      final user = AppUser.fromMap('1', map);

      expect(user.uid, '1');
      expect(user.email, 'test@test.com');
      expect(user.firstName, 'First');
      expect(user.lastName, 'Last');
      expect(user.phone, '12345');
      expect(user.church, 'Myf');
      expect(user.district, 'District');
      expect(user.gender, 'Male');
      expect(user.permissions, ['admin']);
    });

    test('toMap converts AppUser to map', () {
      final user = AppUser(
        uid: '1',
        email: 'test@test.com',
        firstName: 'First',
        lastName: 'Last',
        phone: '12345',
        church: 'Myf',
        district: 'District',
        gender: 'Male',
        permissions: const ['admin'],
      );

      final map = user.toMap();

      expect(map['email'], 'test@test.com');
      expect(map['firstName'], 'First');
      expect(map['lastName'], 'Last');
      expect(map['phone'], '12345');
      expect(map['church'], 'Myf');
      expect(map['district'], 'District');
      expect(map['gender'], 'Male');
      expect(map['permissions'], ['admin']);
      expect(map.containsKey('uid'), isFalse);
    });
  });
}
