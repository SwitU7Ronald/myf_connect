import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/app_router.dart';
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
  bool _loggingOut = false;

  final Color primaryRed = const Color(0xFFB71C1C);
  final Color backgroundGray = const Color(0xFFF5F5F5);
  final Color cardGray = const Color(0xFFFAFAFA);

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

  Future<void> _logout() async {
    if (!mounted) return;

    setState(() => _loggingOut = true);

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    setState(() => _loggingOut = false);

    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
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
                                  (_userModel?.firstName != null &&
                                      _userModel!.firstName!
                                          .isNotEmpty)
                                      ? _userModel!.firstName![0]
                                      .toUpperCase()
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_userModel?.nickname != null &&
                                  _userModel!.nickname!.isNotEmpty)
                                Text(
                                  _userModel!.nickname!,
                                  style: TextStyle(
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
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
                                _userModel?.birthdate
                                    ?.toIso8601String()
                                    .split('T')
                                    .first ??
                                    '-',
                              ),
                              _buildDetailRow(
                                'Gender',
                                _userModel?.gender ?? '-',
                              ),
                              _buildDetailRow(
                                'District',
                                _userModel?.district ?? '-',
                              ),
                              _buildDetailRow(
                                'Church',
                                _userModel?.church ?? '-',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Permissions Card
                      Card(
                        color: cardGray,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
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
                                  final filteredPermissions = (_userModel
                                      ?.permissions ??
                                      [])
                                      .where((perm) => perm != 'general')
                                      .toList();
                                  if (filteredPermissions.isEmpty) {
                                    return const Text(
                                      'No permissions assigned',
                                      style: TextStyle(color: Colors.grey),
                                    );
                                  }
                                  return Container(
                                    constraints:
                                    const BoxConstraints(maxHeight: 100),
                                    child: SingleChildScrollView(
                                      child: Wrap(
                                        spacing: 10,
                                        runSpacing: 8,
                                        children: filteredPermissions
                                            .map(
                                              (perm) => Chip(
                                            label: Text(
                                              perm,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: primaryRed,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                          ),
                                        )
                                            .toList(),
                                      ),
                                    ),
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
                          leading: Icon(Icons.info_outline, color: primaryRed),
                          title: const Text(
                            'Credits',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.credit)
                                .then((_) {
                              // When credits page closes (continue pressed), control returns here.
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons Row for About and Logout
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryRed,
                          side: BorderSide(color: primaryRed),
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Methodist Connect',
                            applicationVersion: '1.0.0',
                            applicationIcon: CircleAvatar(
                              backgroundColor: primaryRed,
                              child: const Icon(Icons.church,
                                  color: Colors.white),
                            ),
                            children: const [
                              SizedBox(height: 10),
                              Text(
                                  'Methodist Connect is an app to connect and manage Methodist community camps, events, and member profiles.'),
                            ],
                          );
                        },
                        child: const Text(
                          'About',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.tonal(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              primaryRed.withOpacity(0.15)),
                          foregroundColor:
                          MaterialStateProperty.all(primaryRed),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8))),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 14)),
                        ),
                        onPressed: _loggingOut ? null : _logout,
                        child: _loggingOut
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                            : const Text(
                          'Logout',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    fontSize: 16)),
          ),
          Expanded(
            flex: 5,
            child:
            Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
