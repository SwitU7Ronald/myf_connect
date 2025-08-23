import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_user.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<List<AppUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<AppUser>> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) => AppUser.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> _toggleAdmin(AppUser user) async {
    final isAdmin = user.permissions.contains('admin');
    final newPermissions = List<String>.from(user.permissions);
    if (isAdmin) {
      newPermissions.remove('admin');
    } else {
      newPermissions.add('admin');
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'permissions': newPermissions});
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: FutureBuilder<List<AppUser>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load users: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isAdmin = user.permissions.contains('admin');
              return ListTile(
                title: Text('${user.firstName ?? ''} ${user.lastName ?? ''}'),
                subtitle: Text(user.phone),
                trailing: Switch(
                  value: isAdmin,
                  onChanged: (_) => _toggleAdmin(user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
