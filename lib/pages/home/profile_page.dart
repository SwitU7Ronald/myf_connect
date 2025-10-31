// lib/pages/home/profile_page.dart
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
  final UserService userService = UserService();
  AppUser? userModel;
  bool loading = true;
  bool loggingOut = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await userService.getUser(user.uid);
        if (mounted) {
          setState(() {
            userModel = userData;
            loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  /// Fetch permission titles organized by type (camps or MYFs)
  Future<Map<String, List<String>>> getOrganizedPermissions(List<String> permissionIds) async {
    if (permissionIds.isEmpty) {
      return {'camps': [], 'myfs': []};
    }

    try {
      final campTitles = <String>[];
      final myfTitles = <String>[];

      // Fetch all camps
      final campsSnapshot = await FirebaseFirestore.instance
          .collection('camps')
          .get();

      // Fetch all MYFs
      final myfsSnapshot = await FirebaseFirestore.instance
          .collection('myfs')
          .get();

      // Create maps for quick lookup
      final campMap = <String, String>{};
      for (final doc in campsSnapshot.docs) {
        final data = doc.data();
        campMap[doc.id] = data['title'] ?? doc.id;
      }

      final myfMap = <String, String>{};
      for (final doc in myfsSnapshot.docs) {
        final data = doc.data();
        myfMap[doc.id] = data['title'] ?? doc.id;
      }

      // Categorize permissions
      for (final permId in permissionIds) {
        if (campMap.containsKey(permId)) {
          campTitles.add(campMap[permId]!);
        } else if (myfMap.containsKey(permId)) {
          myfTitles.add(myfMap[permId]!);
        } else {
          // Unknown permission - could be deleted camp/myf
          debugPrint('Unknown permission ID: $permId');
        }
      }

      // Sort alphabetically
      campTitles.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      myfTitles.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      return {
        'camps': campTitles,
        'myfs': myfTitles,
      };
    } catch (e) {
      debugPrint('Error fetching permission titles: $e');
      return {'camps': [], 'myfs': []};
    }
  }

  Future<void> logout() async {
    if (!mounted || loggingOut) return;

    setState(() {
      loggingOut = true;
    });

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
        ).pushNamedAndRemoveUntil(
          AppRoutes.welcome,
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      if (mounted) {
        MethodistTheme.showErrorSnackBar(context, 'Logout failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          loggingOut = false;
        });
      }
    }
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
      body: loading
          ? const LoadingWidget(message: 'Loading profile...')
          : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: MethodistTheme.paddingL,
                child: Column(
                  children: [
                    buildProfileCard(),
                    SizedBox(height: MethodistTheme.spacingL),
                    buildPersonalDetailsCard(),
                    SizedBox(height: MethodistTheme.spacingL),
                    buildPermissionsCard(),
                  ],
                ),
              ),
            ),
            Container(
              padding: MethodistTheme.paddingM,
              child: Column(
                children: [
                  // Top Row: Credits and Team buttons side by side
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton.secondary(
                          label: 'Credits',
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.credit),
                          fullWidth: true,
                          icon: Icons.info_outline,
                        ),
                      ),
                      SizedBox(width: MethodistTheme.spacingM),
                      Expanded(
                        child: PrimaryButton.secondary(
                          label: 'Team',
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.team),
                          fullWidth: true,
                          icon: Icons.people,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MethodistTheme.spacingM),
                  // Bottom: Logout button - Full Width and Centered
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton.danger(
                      label: 'Logout',
                      onPressed: loggingOut ? null : logout,
                      loading: loggingOut,
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

  Widget buildProfileCard() {
    return MethodistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: MethodistTheme.primaryRed,
            child: Text(
              (userModel?.firstName?.isNotEmpty ?? false)
                  ? userModel!.firstName!.substring(0, 1).toUpperCase()
                  : '?',
              style: MethodistTheme.displaySmall.copyWith(
                color: MethodistTheme.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: MethodistTheme.spacingM),
          if (userModel?.nickname?.isNotEmpty ?? false) ...[
            Text(
              userModel!.nickname!,
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
            '${userModel?.firstName ?? '-'} ${userModel?.lastName ?? ''}',
            style: MethodistTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MethodistTheme.spacingS),
          Text(
            userModel?.phone ?? '',
            style: MethodistTheme.bodyLarge.copyWith(
              color: MethodistTheme.mediumGray,
            ),
          ),
          if (userModel?.email?.isNotEmpty ?? false) ...[
            SizedBox(height: MethodistTheme.spacingXS),
            Text(
              userModel!.email!,
              style: MethodistTheme.bodySmall.copyWith(
                color: MethodistTheme.mediumGray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildPersonalDetailsCard() {
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
          buildDetailRow('Birthdate', userModel?.birthdate?.toIso8601String().split('T').first ?? '-'),
          buildDetailRow('Gender', userModel?.gender ?? '-'),
          buildDetailRow('District', userModel?.district ?? '-'),
          buildDetailRow('Church', userModel?.church ?? '-'),
        ],
      ),
    );
  }

  Widget buildPermissionsCard() {
    return MethodistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user,
                color: MethodistTheme.primaryRed,
                size: 24,
              ),
              SizedBox(width: MethodistTheme.spacingS),
              Text(
                'Approved Permissions',
                style: MethodistTheme.titleLarge,
              ),
            ],
          ),
          Divider(
            height: MethodistTheme.spacingL,
            thickness: 1.2,
            color: MethodistTheme.mediumGray.withValues(alpha: 0.3),
          ),
          Builder(
            builder: (context) {
              final permissions = userModel?.permissions ?? [];

              return FutureBuilder<Map<String, List<String>>>(
                future: getOrganizedPermissions(permissions),
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

                  final organizedPerms = snapshot.data ?? {'camps': [], 'myfs': []};
                  final campPerms = organizedPerms['camps'] ?? [];
                  final myfPerms = organizedPerms['myfs'] ?? [];

                  // IntrinsicHeight makes both boxes match the taller one automatically
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Side - Camp Permissions
                        Expanded(
                          child: _buildPermissionColumn(
                            title: 'Camp Permissions',
                            icon: Icons.campaign,
                            permissions: campPerms,
                            color: MethodistTheme.primaryRed,
                            emptyMessage: 'No camp permissions',
                          ),
                        ),
                        SizedBox(width: MethodistTheme.spacingM),

                        // Right Side - MYF Permissions
                        Expanded(
                          child: _buildPermissionColumn(
                            title: 'MYF Permissions',
                            icon: Icons.group,
                            permissions: myfPerms,
                            color: MethodistTheme.infoBlue,
                            emptyMessage: 'No MYF permissions',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionColumn({
    required String title,
    required IconData icon,
    required List<String> permissions,
    required Color color,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            SizedBox(width: MethodistTheme.spacingXS),
            Expanded(
              child: Text(
                title,
                style: MethodistTheme.titleSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: MethodistTheme.spacingXS),

        // Count Badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: MethodistTheme.spacingS,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
          ),
          child: Text(
            '${permissions.length} ${permissions.length == 1 ? 'permission' : 'permissions'}',
            style: MethodistTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: MethodistTheme.spacingS),

        // Permissions List - ADAPTIVE HEIGHT with Expanded
        Expanded(
          child: Container(
            width: double.infinity,
            padding: MethodistTheme.paddingM,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
              ),
            ),
            child: permissions.isEmpty
                ? Center(child: _buildEmptyPermissionState(emptyMessage, color))
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: permissions
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final permTitle = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < permissions.length - 1
                          ? MethodistTheme.spacingS
                          : 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: color,
                          size: 16,
                        ),
                        SizedBox(width: MethodistTheme.spacingXS),
                        Expanded(
                          child: Text(
                            permTitle,
                            style: MethodistTheme.bodySmall.copyWith(
                              color: MethodistTheme.darkGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPermissionState(String message, Color color) {
    return Column(
      children: [
        Icon(
          Icons.lock_outline,
          color: color.withValues(alpha: 0.3),
          size: 32,
        ),
        SizedBox(height: MethodistTheme.spacingS),
        Text(
          message,
          style: MethodistTheme.bodySmall.copyWith(
            color: MethodistTheme.mediumGray,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildDetailRow(String label, String value) {
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
}
