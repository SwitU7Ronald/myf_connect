import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/app_user.dart';

class UsersManagementPage extends StatelessWidget {
  const UsersManagementPage({super.key});

  Future<void> _setCampPermission({
    required String uid,
    required String campId,
    required bool enabled,
  }) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    await ref.update({
      'permissions': enabled
          ? FieldValue.arrayUnion([campId])
          : FieldValue.arrayRemove([campId]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final campsStream = FirebaseFirestore.instance
        .collection('camps')
        .orderBy('title')
        .snapshots();

    final usersStream = FirebaseFirestore.instance
        .collection('users')
        .orderBy('firstName')
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Users Management')),
      body: StreamBuilder<QuerySnapshot>(
        stream: campsStream,
        builder: (context, campsSnap) {
          if (campsSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (campsSnap.hasError) {
            return const Center(child: Text('Failed to load camps'));
          }

          final campDocs = campsSnap.data?.docs ?? const [];
          final camps = campDocs
              .map(
                (d) => {
                  'id': d.id,
                  'title':
                      (d.data() as Map<String, dynamic>?)?['title'] ?? d.id,
                },
              )
              .toList();

          return StreamBuilder<QuerySnapshot>(
            stream: usersStream,
            builder: (context, usersSnap) {
              if (usersSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (usersSnap.hasError) {
                return const Center(child: Text('Failed to load users'));
              }

              final users =
                  usersSnap.data?.docs
                      .map(
                        (d) => AppUser.fromMap(
                          d.id,
                          d.data() as Map<String, dynamic>,
                        ),
                      )
                      .toList() ??
                  [];

              if (users.isEmpty) {
                return const Center(child: Text('No users found'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: users.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final fullName =
                      '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
                  final perms = user.permissions;

                  return ExpansionTile(
                    title: Text(fullName.isEmpty ? 'Unnamed user' : fullName),
                    subtitle: Text(user.phone.isEmpty ? '-' : user.phone),
                    trailing: Text('${perms.length}'),
                    children: [
                      if (camps.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('No camps available'),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Camp permissions',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: camps.map((camp) {
                                  final campId = camp['id'] as String;
                                  final campTitle = camp['title'] as String;
                                  final selected =
                                      perms.contains(campId) == true;

                                  return FilterChip(
                                    label: Text(campTitle),
                                    selected: selected,
                                    onSelected: (isSelected) {
                                      _setCampPermission(
                                        uid: user.uid,
                                        campId: campId,
                                        enabled: isSelected,
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                    ],
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
