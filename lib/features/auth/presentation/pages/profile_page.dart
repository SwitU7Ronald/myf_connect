import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myf_connect/core/routes/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/core/models/app_user.dart';
import 'package:myf_connect/core/services/auth/auth_bloc.dart';
import 'package:myf_connect/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_snackbars.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
          AppSnackbars.showError(context, state.message);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final userModel = state.appUser;

            return BlocProvider(
              create: (_) =>
                  di.sl<ProfileCubit>()
                    ..loadOrganizedPermissions(userModel.permissions),
              child: PlatformScaffold(
                backgroundColor: context.colors.background,
                appBar: PlatformAppBar(
                  title: const Text('Profile'),
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.surface,
                ),
                body: Padding(padding: EdgeInsets.only(top: context.appBarOverlap), child: SafeArea(
                  child: ResponsiveConstrainedBox(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(context.spacingLg),
                            child: Column(
                              children: [
                                buildProfileCard(userModel),
                                SizedBox(height: context.spacingLg),
                                buildPersonalDetailsCard(userModel),
                                SizedBox(height: context.spacingLg),
                                buildPermissionsCard(userModel),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(context.spacingMd),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: PrimaryButton.secondary(
                                      label: 'Credits',
                                      onPressed: () => context.push(
                                        AppRoutes.credit,
                                      ),
                                      fullWidth: true,
                                      icon: Icons.info_outline,
                                    ),
                                  ),
                                  SizedBox(width: context.spacingMd),
                                  Expanded(
                                    child: PrimaryButton.secondary(
                                      label: 'Team',
                                      onPressed: () => context.push(
                                        AppRoutes.team,
                                      ),
                                      fullWidth: true,
                                      icon: Icons.people,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.spacingMd),
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
              ),
            );
          }

          return PlatformScaffold(
            backgroundColor: context.colors.background,
            appBar: PlatformAppBar(
              title: const Text('Profile'),
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.surface,
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
            backgroundColor: context.colors.primary,
            child: Text(
              (userModel.firstName?.isNotEmpty ?? false)
                  ? userModel.firstName!.substring(0, 1).toUpperCase()
                  : '?',
              style: context.typography.displaySmall!.copyWith(
                color: context.colors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: context.spacingMd),
          if (userModel.nickname?.isNotEmpty ?? false) ...[
            Text(
              userModel.nickname!,
              style: context.typography.titleLarge!.copyWith(
                fontStyle: FontStyle.italic,
                color: context.colors.primary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacingSm),
          ],
          Text(
            '${userModel.firstName ?? '-'} ${userModel.lastName ?? ''}',
            style: context.typography.headlineSmall!,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.spacingSm),
          Text(
            userModel.phone,
            style: context.typography.bodyLarge!.copyWith(color: context.colors.textSecondary),
          ),
          if (userModel.email?.isNotEmpty ?? false) ...[
            SizedBox(height: context.spacingXs),
            Text(
              userModel.email!,
              style: context.typography.bodySmall!.copyWith(color: context.colors.textSecondary),
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
          Text('Personal Details', style: context.typography.titleLarge!),
          Divider(
            height: context.spacingLg,
            thickness: 1.2,
            color: context.colors.textSecondary.withValues(alpha: 0.3),
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
              Icon(
                Icons.verified_user,
                color: context.colors.primary,
                size: context.responsiveIconSize(24),
              ),
              SizedBox(width: context.spacingSm),
              Text('Approved Permissions', style: context.typography.titleLarge!),
            ],
          ),
          Divider(
            height: context.spacingLg,
            thickness: 1.2,
            color: context.colors.textSecondary.withValues(alpha: 0.3),
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
                              color: context.colors.primary,
                              emptyMessage: 'No camp permissions',
                            ),
                          ),
                          SizedBox(width: context.spacingMd),

                          Expanded(
                            child: _buildPermissionColumn(
                              title: 'MYF Permissions',
                              icon: Icons.group,
                              permissions: myfPerms,
                              color: context.colors.info,
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
            Icon(icon, color: color, size: context.responsiveIconSize(18)),
            SizedBox(width: context.spacingXs),
            Expanded(
              child: Text(
                title,
                style: context.typography.titleSmall!.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: context.spacingXs),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacingSm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: context.radiusSm,
          ),
          child: Text(
            '${permissions.length} ${permissions.length == 1 ? 'permission' : 'permissions'}',
            style: context.typography.bodySmall!.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: context.spacingSm),

        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.spacingMd),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: context.radiusMd,
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
                                ? context.spacingSm
                                : 0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: color,
                                size: context.responsiveIconSize(16),
                              ),
                              SizedBox(width: context.spacingXs),
                              Expanded(
                                child: Text(
                                  permTitle,
                                  style: context.typography.bodySmall!.copyWith(
                                    color: context.colors.textPrimary,
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
        Icon(
          Icons.lock_outline,
          color: color.withValues(alpha: 0.3),
          size: context.responsiveIconSize(32),
        ),
        SizedBox(height: context.spacingSm),
        Text(
          message,
          style: context.typography.bodySmall!.copyWith(
            color: context.colors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: context.typography.titleSmall!.copyWith(color: context.colors.textSecondary),
            ),
          ),
          Expanded(flex: 5, child: Text(value, style: context.typography.bodyMedium!)),
        ],
      ),
    );
  }
}
