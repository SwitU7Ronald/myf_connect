// ./lib/pages/home/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../app/app_router.dart';
import '../../services/user_service.dart';
import '../../models/app_user.dart';
import '../../widgets/widgets.dart';

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
        MethodistTheme.showErrorSnackBar(context, 'Error loading profile: $e');
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
        MethodistTheme.showErrorSnackBar(context, 'Logout failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loggingOut = false);
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: MethodistTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: MethodistTheme.titleSmall.copyWith(
                color: MethodistTheme.mediumGray,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: MethodistTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return MethodistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: MethodistTheme.primaryRed,
            child: Text(
              (_userModel?.firstName?.isNotEmpty ?? false)
                  ? _userModel!.firstName!.substring(0, 1).toUpperCase()
                  : '?',
              style: MethodistTheme.displaySmall.copyWith(
                color: MethodistTheme.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: MethodistTheme.spacingM),
          if (_userModel?.nickname?.isNotEmpty ?? false) ...[
            Text(
              _userModel!.nickname!,
              style: MethodistTheme.titleLarge.copyWith(
                fontStyle: FontStyle.italic,
                color: MethodistTheme.primaryRed,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MethodistTheme.spacingS),
          ],
          Text(
            '${_userModel?.firstName ?? '-'} ${_userModel?.lastName ?? ''}',
            style: MethodistTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MethodistTheme.spacingS),
          Text(
            _userModel?.phone ?? '',
            style: MethodistTheme.bodyLarge.copyWith(
              color: MethodistTheme.mediumGray,
            ),
          ),
          if (_userModel?.email?.isNotEmpty ?? false) ...[
            SizedBox(height: MethodistTheme.spacingXS),
            Text(
              _userModel!.email!,
              style: MethodistTheme.bodySmall.copyWith(
                color: MethodistTheme.mediumGray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsCard() {
    return MethodistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Personal Details',
            style: MethodistTheme.titleLarge,
          ),
          Divider(
            height: MethodistTheme.spacingL,
            thickness: 1.2,
            color: MethodistTheme.mediumGray.withValues(alpha: 0.3),
          ),
          _buildDetailRow(
            'Birthdate',
            _userModel?.birthdate?.toIso8601String().split('T').first ?? '-',
          ),
          _buildDetailRow('Gender', _userModel?.gender ?? '-'),
          _buildDetailRow('District', _userModel?.district ?? '-'),
          _buildDetailRow('Church', _userModel?.church ?? '-'),
        ],
      ),
    );
  }

  Widget _buildPermissionsCard() {
    return MethodistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Approvals / Permissions',
            style: MethodistTheme.titleLarge,
          ),
          Divider(
            height: MethodistTheme.spacingL,
            thickness: 1.2,
            color: MethodistTheme.mediumGray.withValues(alpha: 0.3),
          ),
          Builder(
            builder: (context) {
              final permissions = _userModel?.permissions ?? [];
              if (permissions.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.lock_outline,
                  title: 'No Permissions',
                  description: 'No permissions assigned yet',
                );
              }
              return FutureBuilder<List<String>>(
                future: _getPermissionTitles(permissions),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget(message: 'Loading permissions...');
                  }
                  if (snapshot.hasError) {
                    return ErrorStateWidget(
                      title: 'Error Loading Permissions',
                      description: 'Error: ${snapshot.error}',
                      onRetry: () => setState(() {}),
                    );
                  }
                  final titles = snapshot.data ?? [];
                  return Wrap(
                    spacing: MethodistTheme.spacingS,
                    runSpacing: MethodistTheme.spacingS,
                    children: titles
                        .map(
                          (title) => StatusBadge(
                        text: title,
                        type: StatusType.info,
                      ),
                    )
                        .toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MethodistTheme.lightGray,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
      ),
      body: _loading
          ? const LoadingWidget(message: 'Loading profile...')
          : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: MethodistTheme.paddingL,
                child: Column(
                  children: [
                    _buildProfileCard(),
                    SizedBox(height: MethodistTheme.spacingL),
                    _buildPersonalDetailsCard(),
                    SizedBox(height: MethodistTheme.spacingL),
                    _buildPermissionsCard(),
                  ],
                ),
              ),
            ),
            Container(
              padding: MethodistTheme.paddingM,
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton.secondary(
                      label: 'Credits',
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.credit);
                      },
                      fullWidth: true,
                      icon: Icons.info_outline,
                    ),
                  ),
                  SizedBox(width: MethodistTheme.spacingM),
                  Expanded(
                    child: PrimaryButton.danger(
                      label: 'Logout',
                      onPressed: _loggingOut ? null : _logout,
                      loading: _loggingOut,
                      fullWidth: true,
                      icon: Icons.logout,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
