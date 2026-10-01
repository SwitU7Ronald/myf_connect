import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myf_connect/core/config/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/features/auth/data/models/app_user.dart';
import 'package:myf_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:myf_connect/features/auth/presentation/cubit/profile_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<ProfileCubit>().loadOrganizedPermissions(
          authState.appUser.permissions,
        );
      }
    });
  }

  Future<void> logout() async {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.welcome);
        } else if (state is AuthError) {
          MyfTheme.showErrorSnackBar(context, state.message);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final userModel = state.appUser;

            return BlocProvider(
              create: (_) => di.sl<ProfileCubit>(),
              child: Scaffold(
                backgroundColor: MyfTheme.lightGray,
                appBar: AppBar(
                  title: const Text('Profile'),
                  backgroundColor: MyfTheme.primaryRed,
                  foregroundColor: MyfTheme.white,
                ),
                body: SafeArea(
                  child: ResponsiveConstrainedBox(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: MyfTheme.paddingL,
                            child: Column(
                              children: [
                                buildProfileCard(userModel),
                                SizedBox(height: MyfTheme.spacingL),
                                buildPersonalDetailsCard(userModel),
                                SizedBox(height: MyfTheme.spacingL),
                                buildPermissionsCard(userModel),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: MyfTheme.paddingM,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: PrimaryButton.secondary(
                                      label: 'Credits',
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.credit,
                                      ),
                                      fullWidth: true,
                                      icon: Icons.info_outline,
                                    ),
                                  ),
                                  SizedBox(width: MyfTheme.spacingM),
                                  Expanded(
                                    child: PrimaryButton.secondary(
                                      label: 'Team',
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.team,
                                      ),
                                      fullWidth: true,
                                      icon: Icons.people,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: MyfTheme.spacingM),
                              SizedBox(
                                width: double.infinity,
                                child: PrimaryButton.danger(
                                  label: 'Logout',
                                  onPressed: logout,
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
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: MyfTheme.lightGray,
            appBar: AppBar(
              title: const Text('Profile'),
              backgroundColor: MyfTheme.primaryRed,
              foregroundColor: MyfTheme.white,
            ),
            body: const LoadingWidget(message: 'Loading profile...'),
          );
        },
      ),
    );
  }

  Widget buildProfileCard(AppUser userModel) {
    return MyfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: MyfTheme.primaryRed,
            child: Text(
              (userModel.firstName?.isNotEmpty ?? false)
                  ? userModel.firstName!.substring(0, 1).toUpperCase()
                  : '?',
              style: MyfTheme.displaySmall.copyWith(
                color: MyfTheme.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: MyfTheme.spacingM),
          if (userModel.nickname?.isNotEmpty ?? false) ...[
            Text(
              userModel.nickname!,
              style: MyfTheme.titleLarge.copyWith(
                fontStyle: FontStyle.italic,
                color: MyfTheme.primaryRed,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MyfTheme.spacingS),
          ],
          Text(
            '${userModel.firstName ?? '-'} ${userModel.lastName ?? ''}',
            style: MyfTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MyfTheme.spacingS),
          Text(
            userModel.phone,
            style: MyfTheme.bodyLarge.copyWith(color: MyfTheme.mediumGray),
          ),
          if (userModel.email?.isNotEmpty ?? false) ...[
            SizedBox(height: MyfTheme.spacingXS),
            Text(
              userModel.email!,
              style: MyfTheme.bodySmall.copyWith(color: MyfTheme.mediumGray),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildPersonalDetailsCard(AppUser userModel) {
    return MyfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Personal Details', style: MyfTheme.titleLarge),
          Divider(
            height: MyfTheme.spacingL,
            thickness: 1.2,
            color: MyfTheme.mediumGray.withValues(alpha: 0.3),
          ),
          buildDetailRow(
            'Birthdate',
            userModel.birthdate?.toIso8601String().split('T').first ?? '-',
          ),
          buildDetailRow('Gender', userModel.gender ?? '-'),
          buildDetailRow('District', userModel.district ?? '-'),
          buildDetailRow('Church', userModel.church ?? '-'),
        ],
      ),
    );
  }

  Widget buildPermissionsCard(AppUser userModel) {
    return MyfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: MyfTheme.primaryRed, size: 24),
              SizedBox(width: MyfTheme.spacingS),
              Text('Approved Permissions', style: MyfTheme.titleLarge),
            ],
          ),
          Divider(
            height: MyfTheme.spacingL,
            thickness: 1.2,
            color: MyfTheme.mediumGray.withValues(alpha: 0.3),
          ),
          Builder(
            builder: (context) {
              return BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  if (state is ProfilePermissionsLoading ||
                      state is ProfileInitial) {
                    return const LoadingWidget(
                      message: 'Loading permissions...',
                    );
                  }

                  if (state is ProfilePermissionsError) {
                    return ErrorStateWidget(
                      title: 'Error Loading Permissions',
                      description: 'Error: ${state.message}',
                      onRetry: () => context
                          .read<ProfileCubit>()
                          .loadOrganizedPermissions(userModel.permissions),
                    );
                  }

                  if (state is ProfilePermissionsLoaded) {
                    final campPerms = state.camps;
                    final myfPerms = state.myfs;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildPermissionColumn(
                              title: 'Camp Permissions',
                              icon: Icons.campaign,
                              permissions: campPerms,
                              color: MyfTheme.primaryRed,
                              emptyMessage: 'No camp permissions',
                            ),
                          ),
                          SizedBox(width: MyfTheme.spacingM),

                          Expanded(
                            child: _buildPermissionColumn(
                              title: 'MYF Permissions',
                              icon: Icons.group,
                              permissions: myfPerms,
                              color: MyfTheme.infoBlue,
                              emptyMessage: 'No MYF permissions',
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
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
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: MyfTheme.spacingXS),
            Expanded(
              child: Text(
                title,
                style: MyfTheme.titleSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: MyfTheme.spacingXS),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: MyfTheme.spacingS,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(MyfTheme.radiusS),
          ),
          child: Text(
            '${permissions.length} ${permissions.length == 1 ? 'permission' : 'permissions'}',
            style: MyfTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: MyfTheme.spacingS),

        Expanded(
          child: Container(
            width: double.infinity,
            padding: MyfTheme.paddingM,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(MyfTheme.radiusM),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: permissions.isEmpty
                ? Center(child: _buildEmptyPermissionState(emptyMessage, color))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: permissions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final permTitle = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < permissions.length - 1
                                ? MyfTheme.spacingS
                                : 0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, color: color, size: 16),
                              SizedBox(width: MyfTheme.spacingXS),
                              Expanded(
                                child: Text(
                                  permTitle,
                                  style: MyfTheme.bodySmall.copyWith(
                                    color: MyfTheme.darkGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
        Icon(Icons.lock_outline, color: color.withValues(alpha: 0.3), size: 32),
        SizedBox(height: MyfTheme.spacingS),
        Text(
          message,
          style: MyfTheme.bodySmall.copyWith(
            color: MyfTheme.mediumGray,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: MyfTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: MyfTheme.titleSmall.copyWith(color: MyfTheme.mediumGray),
            ),
          ),
          Expanded(flex: 5, child: Text(value, style: MyfTheme.bodyMedium)),
        ],
      ),
    );
  }
}
