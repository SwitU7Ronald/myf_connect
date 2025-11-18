import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/widgets.dart';
import 'camps_detail_page.dart';

class CampsListPage extends StatelessWidget {
  const CampsListPage({super.key});

  Future<List<String>> _getUserPermissions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('CampsListPage: No authenticated user');
        return [];
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint('CampsListPage: User document not found');
        return [];
      }

      final data = userDoc.data();
      final permissions = (data?['permissions'] as List?)?.cast<String>() ?? [];

      debugPrint('CampsListPage: User permissions: $permissions');
      return permissions;
    } catch (e) {
      debugPrint('CampsListPage: Error fetching user permissions: $e');
      return [];
    }
  }

  Stream<Map<String, double>> getCampAverageRating(String campId) {
    return FirebaseFirestore.instance
        .collection('camps')
        .doc(campId)
        .collection('events')
        .where('dateTime', isLessThan: Timestamp.now())
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return {'avgRating': 0.0, 'count': 0.0};
          }

          double totalRating = 0.0;
          int eventCount = 0;

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final avgRating = (data['avgRating'] ?? 0.0).toDouble();
            final numRatings = data['numRatings'] ?? 0;

            if (numRatings > 0) {
              totalRating += avgRating;
              eventCount++;
            }
          }

          return {
            'avgRating': eventCount > 0 ? totalRating / eventCount : 0.0,
            'count': eventCount.toDouble(),
          };
        });
  }

  void _handleCampTap(
    BuildContext context,
    String campId,
    String campTitle,
    List<String> userPermissions,
  ) {
    if (userPermissions.contains(campId)) {
      debugPrint('CampsListPage: User has permission for $campTitle');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CampsDetailPage(campId: campId, campTitle: campTitle),
        ),
      );
    } else {
      debugPrint('CampsListPage: User lacks permission for $campTitle');
      MethodistTheme.showErrorSnackBar(
        context,
        'Access Denied: You need admin approval to view "$campTitle". Please contact an administrator.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camps')),
      body: FutureBuilder<List<String>>(
        future: _getUserPermissions(),
        builder: (context, permSnapshot) {
          if (permSnapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading permissions...');
          }

          if (permSnapshot.hasError) {
            return ErrorStateWidget(
              title: 'Error Loading Permissions',
              description:
                  'Failed to load your permissions: ${permSnapshot.error}',
              onRetry: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CampsListPage()),
                );
              },
            );
          }

          final userPermissions = permSnapshot.data ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('camps')
                .orderBy('date')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LoadingWidget(message: 'Loading camps...');
              }

              if (snapshot.hasError) {
                return ErrorStateWidget(
                  title: 'Error Loading Camps',
                  description: 'Failed to load camps: ${snapshot.error}',
                  onRetry: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CampsListPage()),
                    );
                  },
                );
              }

              final camps = snapshot.data!.docs;

              if (camps.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.campaign,
                  title: 'No Camps Available',
                  description:
                      'Check back later for upcoming camps and events.',
                );
              }

              return ListView.builder(
                padding: MethodistTheme.paddingM,
                itemCount: camps.length,
                itemBuilder: (context, index) {
                  final camp = camps[index];
                  final campId = camp.id;
                  final data = camp.data() as Map<String, dynamic>;
                  final title = data['title'] ?? 'Unnamed Camp';
                  final place = data['place'] ?? '';
                  final description = data['description'] ?? '';

                  String dateStr = '';
                  final dateVal = data['date'];
                  if (dateVal is Timestamp) {
                    dateStr = dateVal
                        .toDate()
                        .toLocal()
                        .toString()
                        .split(' ')
                        .first;
                  } else if (dateVal is String) {
                    final parsedDate = DateTime.tryParse(dateVal);
                    dateStr =
                        parsedDate?.toLocal().toString().split(' ').first ?? '';
                  }

                  final hasPermission = userPermissions.contains(campId);

                  return InfoCard(
                    title: title,
                    subtitle: place.isNotEmpty ? place : null,
                    description:
                        '$dateStr${description.isNotEmpty ? ' • $description' : ''}',
                    icon: Icons.campaign,
                    isLocked: !hasPermission,
                    onTap: () =>
                        _handleCampTap(context, campId, title, userPermissions),
                    trailing: StreamBuilder<Map<String, double>>(
                      stream: getCampAverageRating(campId),
                      builder: (context, ratingSnapshot) {
                        if (!ratingSnapshot.hasData ||
                            ratingSnapshot.data!['count']! == 0) {
                          return const SizedBox.shrink();
                        }

                        final ratingData = ratingSnapshot.data!;
                        final avgRating = ratingData['avgRating']!;

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: MethodistTheme.warningOrange,
                              size: 18,
                            ),
                            SizedBox(width: MethodistTheme.spacingXS),
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: MethodistTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: MethodistTheme.warningOrange,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
