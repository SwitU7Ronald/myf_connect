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
    if (!context.mounted) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userModel = await _userService.getUser(user.uid);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<List<String>> _getPermissionTitles(List<String> uids) async {
    final db = FirebaseFirestore.instance;
    final titles = <String>[];
    try {
      for (final uid in uids) {
        final campDoc = await db.collection('camps').doc(uid).get();
        if (campDoc.exists) {
          titles.add(campDoc.data()?['title'] ?? uid);
          continue;
        }
        final myfDoc = await db.collection('myfs').doc(uid).get();
        if (myfDoc.exists) {
          titles.add(myfDoc.data()?['title'] ?? uid);
          continue;
        }
        titles.add(uid);
      }
    } catch (e) {
      debugPrint('Error fetching permission titles: $e');
      return uids;
    }
    return titles;
  }

  Future<void> _logout() async {
    if (!mounted || _loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      final google = GoogleSignIn();
      if (await google.isSignedIn()) {
        try {
          await google.disconnect();
        } catch (e) {
          debugPrint('Google disconnect error: $e');
        }
        await google.signOut();
      }
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loggingOut = false);
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildProfileCard() {
    return Card(
      color: cardGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    ? _userModel!.firstName!.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            if (_userModel?.nickname?.isNotEmpty ?? false)
              const SizedBox(height: 8),
            Text(
              '${_userModel?.firstName ?? '-'} ${_userModel?.lastName ?? ''}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _userModel?.phone ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            if (_userModel?.email?.isNotEmpty ?? false) ...[
              const SizedBox(height: 4),
              Text(
                _userModel!.email!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsCard() {
    return Card(
      color: cardGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  Widget _buildPermissionsCard() {
    return Card(
      color: cardGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              builder: (context) {
                final permissions = _userModel?.permissions ?? [];
                if (permissions.isEmpty) {
                  return const Text(
                    'No permissions assigned',
                    style: TextStyle(color: Colors.grey),
                  );
                }
                return FutureBuilder<List<String>>(
                  future: _getPermissionTitles(permissions),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Error loading permissions: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    final titles = snapshot.data ?? [];
                    return Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: titles
                              .map(
                                (title) => Chip(
                                  label: Text(
                                    title,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: primaryRed,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                ),
                              )
                              .toList(),
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
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            )
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
                            _buildProfileCard(),
                            const SizedBox(height: 20),
                            _buildPersonalDetailsCard(),
                            const SizedBox(height: 20),
                            _buildPermissionsCard(),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.credit);
                              },
                              child: const Text(
                                'Credits',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  primaryRed,
                                ),
                                foregroundColor: WidgetStateProperty.all<Color>(
                                  Colors.white,
                                ),
                                shape: WidgetStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                padding:
                                    WidgetStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.symmetric(vertical: 14),
                                    ),
                              ),
                              onPressed: _loggingOut ? null : _logout,
                              child: _loggingOut
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
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
