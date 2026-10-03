import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, List<String>>> fetchPermissionTitles(
    List<String> permissionIds,
  ) async {
    final campTitles = <String>[];
    final myfTitles = <String>[];

    if (permissionIds.isEmpty) {
      return {'camps': campTitles, 'myfs': myfTitles};
    }

    try {
      // Since permissionIds could be larger than 10, we'll fetch them individually or in chunks.
      // For simplicity and to avoid the "in" clause limit of 10, we fetch individually in parallel.
      final futures = permissionIds.map((id) async {
        // Check if it's a camp
        final campDoc = await _firestore.collection('camps').doc(id).get();
        if (campDoc.exists && campDoc.data() != null) {
          final title = campDoc.data()!['title'] as String?;
          if (title != null) campTitles.add(title);
          return;
        }

        // If not a camp, check if it's a myf
        final myfDoc = await _firestore.collection('myfs').doc(id).get();
        if (myfDoc.exists && myfDoc.data() != null) {
          final title = myfDoc.data()!['title'] as String?;
          if (title != null) myfTitles.add(title);
        }
      });

      await Future.wait(futures);

      campTitles.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      myfTitles.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      return {'camps': campTitles, 'myfs': myfTitles};
    } catch (e) {
      throw Exception('Failed to fetch permission titles: $e');
    }
  }
}
