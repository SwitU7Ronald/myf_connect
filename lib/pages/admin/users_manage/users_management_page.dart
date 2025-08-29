import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/app_user.dart';

class UsersManagementPage extends StatelessWidget {
  const UsersManagementPage({super.key});

  Future<void> _toggleCampPermission(AppUser user, String campId) async {
    final newPermissions = List<String>.from(user.permissions);
    if (newPermissions.contains(campId)) {
      newPermissions.remove(campId);
    } else {
      newPermissions.add(campId);
    }
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'permissions': newPermissions,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users Management')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());

          final users = snap.data!.docs
              .map(
                (d) => AppUser.fromMap(d.id, d.data() as Map<String, dynamic>),
              )
              .toList();
          if (users.isEmpty) return const Center(child: Text('No users found'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final user = users[index];
              final hasPermission = user.permissions.contains(
                'godhra_camp_2025',
              );
              return ListTile(
                title: Text('${user.firstName ?? ''} ${user.lastName ?? ''}'),
                subtitle: Text(user.phone),
                trailing: Switch(
                  value: hasPermission,
                  onChanged: (_) =>
                      _toggleCampPermission(user, 'godhra_camp_2025'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
