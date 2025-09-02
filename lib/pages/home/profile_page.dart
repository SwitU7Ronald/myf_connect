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
      padding: EdgeInsets.only(bottom: context.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: context.titleSmall.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: context.bodyMedium,
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
            backgroundColor: context.primaryColor,
            child: Text(
              (_userModel?.firstName?.isNotEmpty ?? false)
                  ? _userModel!.firstName!.substring(0, 1).toUpperCase()
                  : '?',
              style: context.displaySmall.copyWith(
                color: MethodistTheme.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: context.spacingM),
          if (_userModel?.nickname?.isNotEmpty ?? false) ...[
            Text(
              _userModel!.nickname!,
              style: context.titleLarge.copyWith(
                fontStyle: FontStyle.italic,
                color: context.primaryColor,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacingS),
          ],
          Text(
            '${_userModel?.firstName ?? '-'} ${_userModel?.lastName ?? ''}',
            style: context.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.spacingS),
          Text(
            _userModel?.phone ?? '',
            style: context.bodyLarge.copyWith(
              color: context.textSecondary,
            ),
          ),
          if (_userModel?.email?.isNotEmpty ?? false) ...[
            SizedBox(height: context.spacingXS),
            Text(
              _userModel!.email!,
              style: context.bodySmall.copyWith(
                color: context.textSecondary,
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
            style: context.titleLarge,
          ),
          Divider(
            height: context.spacingL,
            thickness: 1.2,
            color: context.textSecondary.withOpacity(0.3),
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
            style: context.titleLarge,
          ),
          Divider(
            height: context.spacingL,
            thickness: 1.2,
            color: context.textSecondary.withOpacity(0.3),
          ),
          Builder(
            builder: (context) {
              final permissions = _userModel?.permissions ?? [];
              if (permissions.isEmpty) {
                return EmptyStateWidget(
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
                    spacing: context.spacingS,
                    runSpacing: context.spacingS,
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
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
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
                    SizedBox(height: context.spacingL),
                    _buildPersonalDetailsCard(),
                    SizedBox(height: context.spacingL),
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
                  SizedBox(width: context.spacingM),
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