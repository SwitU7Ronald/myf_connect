import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../app/app_router.dart';
import '../../services/user_service.dart';
import '../../models/app_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  AppUser? _userModel;

  bool _loading = true;
  bool _loggingOut = false;

  static const Color primaryRed = Color(0xFFB71C1C);
  static const Color backgroundGray = Color(0xFFF5F5F5);
  static const Color cardGray = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userModel = await _userService.getUser(user.uid);
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<List<String>> _getPermissionTitles(List<String> uids) async {
    final db = FirebaseFirestore.instance;
    final titles = <String>[];
    for (final uid in uids) {
      // Only supporting camps in this example. Add MYF logic if needed.
      final doc = await db.collection('camps').doc(uid).get();
      titles.add(doc.exists ? (doc.data()?['title'] ?? uid) : uid);
    }
    return titles;
  }


  Future<void> _logout() async {
    if (!mounted) return;
    setState(() => _loggingOut = true);
    try {
      final google = GoogleSignIn();
      if (await google.isSignedIn()) {
        try { await google.disconnect(); } catch (_) {}
        await google.signOut();
      }
      await FirebaseAuth.instance.signOut();
      // Reveal the home route so StreamBuilder shows Welcome
      if (mounted) {
        Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }



  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: primaryRed,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      // Profile Info Card
                      Card(
                        color: cardGray,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: primaryRed,
                                child: Text(
                                  (_userModel?.firstName?.isNotEmpty ?? false)
                                      ? _userModel!.firstName![0].toUpperCase()
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_userModel?.nickname?.isNotEmpty ?? false)
                                Text(
                                  _userModel!.nickname!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                    color: primaryRed,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              const SizedBox(height: 6),
                              Text(
                                '${_userModel?.firstName ?? '-'} ${_userModel?.lastName ?? ''}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _userModel?.phone ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Personal Details Card
                      Card(
                        color: cardGray,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Personal Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const Divider(height: 24, thickness: 1.2),
                              _buildDetailRow(
                                'Birthdate',
                                _userModel?.birthdate?.toIso8601String().split('T').first ?? '-',
                              ),
                              _buildDetailRow('Gender', _userModel?.gender ?? '-'),
                              _buildDetailRow('District', _userModel?.district ?? '-'),
                              _buildDetailRow('Church', _userModel?.church ?? '-'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Permissions / Approvals Card with titles fetched
                      Card(
                        color: cardGray,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Approvals / Permissions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const Divider(height: 24, thickness: 1.2),
                              Builder(
                                builder: (_) {
                                  final filteredPermissions = (_userModel?.permissions ?? []).toList();
                                  if (filteredPermissions.isEmpty) {
                                    return const Text(
                                      'No permissions assigned',
                                      style: TextStyle(color: Colors.grey),
                                    );
                                  }
                                  return FutureBuilder<List<String>>(
                                    future: _getPermissionTitles(filteredPermissions),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError) {
                                        return const Text(
                                          'Failed to load camp titles',
                                          style: TextStyle(color: Colors.red),
                                        );
                                      }
                                      final titles = snapshot.data ?? [];
                                      return Container(
                                        constraints: const BoxConstraints(maxHeight: 100),
                                        child: SingleChildScrollView(
                                          child: Wrap(
                                            spacing: 10,
                                            runSpacing: 8,
                                            children: titles.map((title) => Chip(
                                              label: Text(title, style: const TextStyle(color: Colors.white)),
                                              backgroundColor: primaryRed,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            )).toList(),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),

                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Credits Card
                      Card(
                        color: cardGray,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: primaryRed,
                          ),
                          title: const Text(
                            'Credits',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.credit);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryRed,
                          side: const BorderSide(color: primaryRed),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Methodist Connect',
                            applicationVersion: '1.0.0',
                            applicationIcon: CircleAvatar(
                              backgroundColor: primaryRed,
                              child: const Icon(
                                Icons.church,
                                color: Colors.white,
                              ),
                            ),
                            children: const [
                              SizedBox(height: 10),
                              Text(
                                'Methodist Connect is an app to connect and manage Methodist community camps, events, and member profiles.',
                              ),
                            ],
                          );
                        },
                        child: const Text(
                          'About',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.tonal(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(primaryRed.withOpacity(0.15)),
                          foregroundColor: MaterialStateProperty.all(primaryRed),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 14)),
                        ),
                        onPressed: _loggingOut ? null : _logout,
                        child: _loggingOut
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text(
                          'Logout',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
