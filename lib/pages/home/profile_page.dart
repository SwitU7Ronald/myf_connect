import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app_router.dart';
import '../../services/user_service.dart';
import '../../models/app_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _users = UserService();
  AppUser? _userModel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userModel = await _users.getUser(uid);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userModel?.phone ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('${_userModel?.firstName ?? '-'} ${_userModel?.lastName ?? ''}'),
                    Text('Birthdate: ${_userModel?.birthdate?.toString().split(' ').first ?? '-'}'),
                    Text('Gender: ${_userModel?.gender ?? '-'}'),
                    Text('State: ${_userModel?.state ?? '-'}'),
                    Text('City: ${_userModel?.city ?? '-'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Approvals/Permissions', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (_userModel?.permissions ?? const ['general'])
                          .map((p) => Chip(label: Text(p)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FilledButton.tonal(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
                }

              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
