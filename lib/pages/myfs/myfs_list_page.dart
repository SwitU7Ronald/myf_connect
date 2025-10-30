import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/widgets.dart';
import 'myfs_detail_page.dart';

class MyfsListPage extends StatelessWidget {
  const MyfsListPage({super.key});

  /// Fetch current user's permissions from Firestore
  Future<List<String>> _getUserPermissions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('MyfsListPage: No authenticated user');
        return [];
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint('MyfsListPage: User document not found');
        return [];
      }

      final data = userDoc.data() as Map<String, dynamic>?;
      final permissions = (data?['permissions'] as List?)?.cast<String>() ?? [];

      debugPrint('MyfsListPage: User permissions: $permissions');
      return permissions;
    } catch (e) {
      debugPrint('MyfsListPage: Error fetching user permissions: $e');
      return [];
    }
  }

  /// Handle MYF tap with permission check
  void _handleMyfTap(
      BuildContext context,
      String myfId,
      String myfTitle,
      List<String> userPermissions,
      ) {
    // Check if user has permission for this specific MYF
    if (userPermissions.contains(myfId)) {
      // User has permission - navigate to MYF detail page
      debugPrint('MyfsListPage: User has permission for $myfTitle');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MyfsDetailPage(
            myfId: myfId,
            myfTitle: myfTitle,
          ),
        ),
      );
    } else {
      // User doesn't have permission - show error message
      debugPrint('MyfsListPage: User lacks permission for $myfTitle');
      MethodistTheme.showErrorSnackBar(
        context,
        'Access Denied: You need admin approval to view "$myfTitle". Please contact an administrator.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MYF Groups')),
      body: FutureBuilder<List<String>>(
        future: _getUserPermissions(),
        builder: (context, permSnapshot) {
          // Show loading while fetching permissions
          if (permSnapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading permissions...');
          }

          // Handle permission fetch error
          if (permSnapshot.hasError) {
            return ErrorStateWidget(
              title: 'Error Loading Permissions',
              description: 'Failed to load your permissions: ${permSnapshot.error}',
              onRetry: () {
                // Trigger rebuild to retry
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MyfsListPage()),
                );
              },
            );
          }

          final userPermissions = permSnapshot.data ?? [];

          // Now fetch MYF groups list
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('myfs')
                .orderBy('title')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget(message: 'Loading MYF groups...');
              }

              if (snapshot.hasError) {
                return ErrorStateWidget(
                  title: 'Error Loading MYF Groups',
                  description: 'Error: ${snapshot.error}',
                  onRetry: () {
                    // Trigger rebuild by navigating
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MyfsListPage()),
                    );
                  },
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.group,
                  title: 'No MYF Groups Available',
                  description: 'Check back later for MYF groups and events.',
                );
              }

              final myfDocs = snapshot.data!.docs;

              return ListView.builder(
                padding: MethodistTheme.paddingM,
                itemCount: myfDocs.length,
                itemBuilder: (context, index) {
                  final myf = myfDocs[index];
                  final myfId = myf.id;
                  final data = myf.data() as Map<String, dynamic>;
                  final title = data['title'] ?? 'Untitled MYF';
                  final description = data['description'] ?? '';

                  // Check if user has permission for this MYF
                  final hasPermission = userPermissions.contains(myfId);

                  return InfoCard(
                    title: title,
                    description: description.isNotEmpty
                        ? description
                        : 'No description available',
                    icon: Icons.group,
                    isLocked: !hasPermission,
                    onTap: () => _handleMyfTap(context, myfId, title, userPermissions),
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
