import 'package:flutter/material.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/models/app_user.dart';
import 'package:myf_connect/features/admin/presentation/widgets/status_widgets.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


class UserCardItem extends StatelessWidget {
  final AppUser user;
  final List<Map<String, Object>> camps;
  final List<Map<String, Object>> myfs;
  final void Function(String id, bool enabled) onCampPermissionChanged;
  final void Function(String id, bool enabled) onMyfPermissionChanged;

  const UserCardItem({
    super.key,
    required this.user,
    required this.camps,
    required this.myfs,
    required this.onCampPermissionChanged,
    required this.onMyfPermissionChanged,
  });

  String get _fullName =>
      '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

  String get _initials {
    if (_fullName.isEmpty) return '?';
    final parts = _fullName.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final perms = user.permissions;

    return MyfCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: context.spacingMd, vertical: context.spacingSm),
          childrenPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: context.colors.primary.withValues(alpha: 0.1),
            child: Text(
              _initials,
              style: context.typography.bodyMedium!.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            _fullName.isEmpty ? 'Unnamed User' : _fullName,
            style: context.typography.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.spacingXs),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: context.responsiveIconSize(14),
                    color: context.colors.textSecondary,
                  ),
                  SizedBox(width: context.spacingXs),
                  Expanded(
                    child: Text(
                      user.phone.isEmpty ? 'No phone' : user.phone,
                      style: context.typography.bodySmall!.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if ((user.district ?? '').isNotEmpty) ...[
                SizedBox(height: context.spacing(2)),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: context.responsiveIconSize(14),
                      color: context.colors.textSecondary,
                    ),
                    SizedBox(width: context.spacingXs),
                    Expanded(
                      child: Text(
                        user.district!,
                        style: context.typography.bodySmall!.copyWith(
                          color: context.colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: StatusBadge(
            text: '${perms.length}',
            type: perms.isEmpty ? StatusType.neutral : StatusType.success,
            isSmall: true,
          ),
          children: [_buildUserDetails(context)],
        ),
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.spacingMd),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.radiusMd.topLeft.x),
          bottomRight: Radius.circular(context.radiusMd.topLeft.x),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, Icons.person, 'User Information'),
          SizedBox(height: context.spacingSm),
          _buildInfoCard(context, [
            if ((user.district ?? '').isNotEmpty)
              _buildInfoRow(
                context,
                Icons.location_city,
                'District',
                user.district ?? '',
              ),
            if ((user.church ?? '').isNotEmpty)
              _buildInfoRow(context, Icons.church, 'Church', user.church ?? ''),
            if ((user.gender ?? '').isNotEmpty)
              _buildInfoRow(context, Icons.wc, 'Gender', user.gender ?? ''),
          ]),
          SizedBox(height: context.spacingLg),
          _buildSectionHeader(
            context,
            Icons.security,
            'Permissions Manager',
            subtitle: '${user.permissions.length} active permissions',
          ),
          SizedBox(height: context.spacingMd),
          if (camps.isEmpty)
            _buildNoItemsAvailable(
              context,
              'Camps',
              'No camps available for permission assignment',
              Icons.campaign_outlined,
            )
          else
            _buildPermissionsSection(
              context: context,
              title: 'Camp Permissions',
              icon: Icons.campaign,
              items: camps,
              userPermissions: user.permissions,
              onPermissionChanged: onCampPermissionChanged,
            ),
          SizedBox(height: context.spacingMd),
          if (myfs.isEmpty)
            _buildNoItemsAvailable(
              context,
              'MYF Groups',
              'No MYF groups available for permission assignment',
              Icons.group_outlined,
            )
          else
            _buildPermissionsSection(
              context: context,
              title: 'MYF Group Permissions',
              icon: Icons.group,
              items: myfs,
              userPermissions: user.permissions,
              onPermissionChanged: onMyfPermissionChanged,
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title, {
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(context.spacingSm),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: context.radiusSm,
          ),
          child: Icon(
            icon,
            color: context.colors.primary,
            size: context.responsiveIconSize(20),
          ),
        ),
        SizedBox(width: context.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.typography.titleSmall!.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: context.typography.bodySmall!.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(context.spacingMd),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radiusMd,
        border: Border.all(color: context.colors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isMonospace = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: context.responsiveIconSize(18),
            color: context.colors.primary.withValues(alpha: 0.7),
          ),
          SizedBox(width: context.spacingMd),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: context.typography.bodySmall!.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.typography.bodySmall!.copyWith(
                color: context.colors.textPrimary,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoItemsAvailable(
    BuildContext context,
    String itemType,
    String message,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(context.spacingMd),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radiusMd,
        border: Border.all(color: context.colors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.spacingMd),
            decoration: BoxDecoration(
              color: context.colors.textSecondary.withValues(alpha: 0.1),
              borderRadius: context.radiusMd,
            ),
            child: Icon(
              icon,
              color: context.colors.textSecondary,
              size: context.responsiveIconSize(28),
            ),
          ),
          SizedBox(width: context.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No $itemType Available',
                  style: context.typography.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.spacingXs),
                Text(
                  message,
                  style: context.typography.bodySmall!.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Map<String, Object>> items,
    required List<String> userPermissions,
    required void Function(String id, bool enabled) onPermissionChanged,
  }) {
    final grantedCount = items
        .where((item) => userPermissions.contains(item['id']))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: context.colors.primary,
                  size: context.responsiveIconSize(18),
                ),
                SizedBox(width: context.spacingSm),
                Text(
                  title,
                  style: context.typography.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            StatusBadge(
              text: '$grantedCount/${items.length}',
              type: grantedCount > 0 ? StatusType.success : StatusType.neutral,
              isSmall: true,
            ),
          ],
        ),
        SizedBox(height: context.spacingSm),
        Container(
          padding: EdgeInsets.all(context.spacingMd),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: context.radiusMd,
            border: Border.all(
              color: context.colors.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: Wrap(
            spacing: context.spacingSm,
            runSpacing: context.spacingSm,
            children: items.map((item) {
              final itemId = item['id'] as String;
              final itemTitle = item['title'] as String;
              final selected = userPermissions.contains(itemId);

              return PermissionChip(
                text: itemTitle,
                isSelected: selected,
                onChanged: (isSelected) =>
                    onPermissionChanged(itemId, isSelected),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
