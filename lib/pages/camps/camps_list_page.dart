import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import '../../models/app_user.dart';
import '../../app_router.dart';

class CampsListPage extends StatefulWidget {
  const CampsListPage({super.key});

  @override
  State<CampsListPage> createState() => _CampsListPageState();
}

class _CampsListPageState extends State<CampsListPage> {
  final _users = UserService();
  AppUser? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _user = await _users.getUser(uid);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final permitted = _user?.permissions.contains('godhra_camp_2025') ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Camps')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (permitted)
            ListTile(
              title: const Text('Godhra Camp 2025'),
              subtitle: const Text('Open to approved users'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.godhraCamp),
            )
          else
            const ListTile(
              title: Text('Godhra Camp 2025'),
              subtitle: Text('Waiting for admin approval'),
              trailing: Icon(Icons.lock),
            ),
        ],
      ),
    );
  }
}
