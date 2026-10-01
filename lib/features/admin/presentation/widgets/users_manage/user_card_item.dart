import 'package:flutter/material.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/features/auth/data/models/app_user.dart';
import 'package:myf_connect/features/admin/presentation/widgets/status_widgets.dart';

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

  String get _fullName => '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

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
          tilePadding: context.responsivePadding(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: MyfTheme.primaryRed.withValues(alpha: 0.1),
            child: Text(
              _initials,
              style: context.responsiveBodyMedium.copyWith(
                color: MyfTheme.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            _fullName.isEmpty ? 'Unnamed User' : _fullName,
            style: context.responsiveTitleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.spacing(4)),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: context.responsiveIconSize(14),
                    color: MyfTheme.mediumGray,
                  ),
                  SizedBox(width: context.spacing(4)),
                  Text(
                    user.phone.isEmpty ? 'No phone' : user.phone,
                    style: context.responsiveBodySmall.copyWith(
                      color: MyfTheme.mediumGray,
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
                      color: MyfTheme.mediumGray,
                    ),
                    SizedBox(width: context.spacing(4)),
                    Text(
                      user.district!,
                      style: context.responsiveBodySmall.copyWith(
                        color: MyfTheme.mediumGray,
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
      padding: context.responsivePadding(all: 16),
      decoration: BoxDecoration(
        color: MyfTheme.lightGray,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.responsiveRadius(12)),
          bottomRight: Radius.circular(context.responsiveRadius(12)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, Icons.person, 'User Information'),
          SizedBox(height: context.spacing(8)),
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
          SizedBox(height: context.spacing(20)),
          _buildSectionHeader(
            context,
            Icons.security,
            'Permissions Manager',
            subtitle: '${user.permissions.length} active permissions',
          ),
          SizedBox(height: context.spacing(12)),
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
          SizedBox(height: context.spacing(16)),
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
          padding: context.responsivePadding(all: 8),
          decoration: BoxDecoration(
            color: MyfTheme.primaryRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
          ),
          child: Icon(
            icon,
            color: MyfTheme.primaryRed,
            size: context.responsiveIconSize(20),
          ),
        ),
        SizedBox(width: context.spacing(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.responsiveTitleSmall.copyWith(
                  color: MyfTheme.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: context.responsiveBodySmall.copyWith(
                    color: MyfTheme.mediumGray,
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
      padding: context.responsivePadding(all: 12),
      decoration: BoxDecoration(
        color: MyfTheme.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        border: Border.all(color: MyfTheme.mediumGray.withValues(alpha: 0.2)),
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
      padding: EdgeInsets.symmetric(vertical: context.spacing(6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: context.responsiveIconSize(18),
            color: MyfTheme.primaryRed.withValues(alpha: 0.7),
          ),
          SizedBox(width: context.spacing(12)),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: context.responsiveBodySmall.copyWith(
                color: MyfTheme.mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.responsiveBodySmall.copyWith(
                color: MyfTheme.darkGray,
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
      padding: context.responsivePadding(all: 16),
      decoration: BoxDecoration(
        color: MyfTheme.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        border: Border.all(color: MyfTheme.mediumGray.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: context.responsivePadding(all: 12),
            decoration: BoxDecoration(
              color: MyfTheme.mediumGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.responsiveRadius(10)),
            ),
            child: Icon(
              icon,
              color: MyfTheme.mediumGray,
              size: context.responsiveIconSize(28),
            ),
          ),
          SizedBox(width: context.spacing(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No $itemType Available',
                  style: context.responsiveTitleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.spacing(4)),
                Text(
                  message,
                  style: context.responsiveBodySmall.copyWith(
                    color: MyfTheme.mediumGray,
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
                  color: MyfTheme.primaryRed,
                  size: context.responsiveIconSize(18),
                ),
                SizedBox(width: context.spacing(8)),
                Text(
                  title,
                  style: context.responsiveTitleSmall.copyWith(
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
        SizedBox(height: context.spacing(8)),
        Container(
          padding: context.responsivePadding(all: 12),
          decoration: BoxDecoration(
            color: MyfTheme.white,
            borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
            border: Border.all(
              color: MyfTheme.mediumGray.withValues(alpha: 0.2),
            ),
          ),
          child: Wrap(
            spacing: context.spacing(8),
            runSpacing: context.spacing(8),
            children: items.map((item) {
              final itemId = item['id'] as String;
              final itemTitle = item['title'] as String;
              final selected = userPermissions.contains(itemId);

              return PermissionChip(
                text: itemTitle,
                isSelected: selected,
                onChanged: (isSelected) => onPermissionChanged(itemId, isSelected),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
