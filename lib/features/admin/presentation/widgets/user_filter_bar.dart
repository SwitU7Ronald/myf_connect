import 'package:flutter/material.dart';
import 'package:myf_connect/core/widgets/widgets.dart';

import 'package:myf_connect/features/admin/presentation/widgets/users_manage/user_filter_enums.dart';
import 'package:myf_connect/features/admin/presentation/widgets/users_manage/filter_components.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


class UserFilterBar extends StatefulWidget {
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final SortBy sortBy;
  final ValueChanged<SortBy> onSortByChanged;
  final SortOrder sortOrder;
  final ValueChanged<SortOrder> onSortOrderChanged;
  final List<Map<String, Object>> camps;
  final List<Map<String, Object>> myfs;
  final String? selectedCampId;
  final String? selectedMyfId;
  final ValueChanged<String?> onCampChanged;
  final ValueChanged<String?> onMyfChanged;
  final PermissionFilter permFilter;
  final ValueChanged<PermissionFilter> onPermFilterChanged;
  final PermissionType permissionType;
  final ValueChanged<PermissionType> onPermissionTypeChanged;
  final List<String> genders;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final List<String> districts;
  final String? selectedDistrict;
  final ValueChanged<String?> onDistrictChanged;
  final VoidCallback onClear;

  const UserFilterBar({
    super.key,
    required this.searchController,
    required this.searchFocus,
    required this.sortBy,
    required this.onSortByChanged,
    required this.sortOrder,
    required this.onSortOrderChanged,
    required this.camps,
    required this.myfs,
    required this.selectedCampId,
    required this.selectedMyfId,
    required this.onCampChanged,
    required this.onMyfChanged,
    required this.permFilter,
    required this.onPermFilterChanged,
    required this.permissionType,
    required this.onPermissionTypeChanged,
    required this.genders,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.districts,
    required this.selectedDistrict,
    required this.onDistrictChanged,
    required this.onClear,
  });

  @override
  State<UserFilterBar> createState() => _UserFilterBarState();
}

class _UserFilterBarState extends State<UserFilterBar> {
  bool _showPermissionFilters = false;

  @override
  Widget build(BuildContext context) {
    final activeItems = widget.permissionType == PermissionType.camps
        ? widget.camps
        : widget.myfs;
    final selectedId = widget.permissionType == PermissionType.camps
        ? widget.selectedCampId
        : widget.selectedMyfId;
    final onChanged = widget.permissionType == PermissionType.camps
        ? widget.onCampChanged
        : widget.onMyfChanged;

    return MyfCard(
      margin: EdgeInsets.fromLTRB(
        context.spacingMd,
        context.spacingSm,
        context.spacingMd,
        context.spacingSm,
      ),
      padding: EdgeInsets.all(context.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          SizedBox(height: context.spacingMd),
          _buildSearchField(),
          SizedBox(height: context.spacingMd),
          _buildSortRow(),
          SizedBox(height: context.spacingMd),
          _buildDemographicsRow(),
          SizedBox(height: context.spacingMd),
          _buildPermissionToggle(),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showPermissionFilters
                ? _buildPermissionFilters(activeItems, selectedId, onChanged)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filters & Search',
          style: context.typography.bodyMedium?.copyWith(
            fontSize: context.responsiveFontSize(16),
            fontWeight: FontWeight.bold,
            color: context.colors.primary,
          ),
        ),
        TextButton.icon(
          onPressed: widget.onClear,
          icon: Icon(Icons.clear_all, size: context.responsiveIconSize(16)),
          label: Text('Clear All'),
          style: TextButton.styleFrom(
            foregroundColor: context.colors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: context.spacingSm,
              vertical: context.spacingXs,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: widget.searchController,
      focusNode: widget.searchFocus,
      decoration: InputDecoration(
        hintText: 'Search users',
        hintStyle: context.typography.bodyMedium?.copyWith(
          fontSize: context.responsiveFontSize(14),
          color: context.colors.textSecondary,
        ),
        prefixIcon: Icon(
          Icons.search,
          size: context.responsiveIconSize(20),
          color: context.colors.textSecondary,
        ),
        suffixIcon: widget.searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, size: context.responsiveIconSize(18)),
                onPressed: () {
                  widget.searchController.clear();
                  widget.searchFocus.unfocus();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radiusM),
          borderSide: BorderSide(
            color: context.colors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radiusM),
          borderSide: BorderSide(
            color: context.colors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radiusM),
          borderSide: BorderSide(color: context.colors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: context.colors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.spacingMd,
          vertical: context.spacingMd,
        ),
        isDense: true,
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => widget.searchFocus.unfocus(),
      style: context.typography.bodyMedium!,
    );
  }

  Widget _buildSortRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: context.typography.bodyMedium?.copyWith(
            fontSize: context.responsiveFontSize(12),
            fontWeight: FontWeight.w600,
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: context.spacingXs),
        Row(
          children: [
            Expanded(
              child: Container(
                height: context.spacingXxl,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  border: Border.all(
                    color: context.colors.textSecondary.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(context.radiusS),
                ),
                child: DropdownButtonFormField<SortBy>(
                  initialValue: widget.sortBy,
                  items: const [
                    DropdownMenuItem(value: SortBy.name, child: Text('Name')),
                    DropdownMenuItem(value: SortBy.phone, child: Text('Phone')),
                    DropdownMenuItem(
                      value: SortBy.district,
                      child: Text('District'),
                    ),
                    DropdownMenuItem(
                      value: SortBy.permissions,
                      child: Text('Permissions'),
                    ),
                  ],
                  onChanged: (v) =>
                      v != null ? widget.onSortByChanged(v) : null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.spacingMd,
                      vertical: context.spacing(10),
                    ),
                    isDense: true,
                  ),
                  isExpanded: true,
                  menuMaxHeight: 250,
                  style: context.typography.bodyMedium?.copyWith(
                    fontSize: context.responsiveFontSize(14),
                    color: context.colors.textPrimary,
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(width: context.spacingMd),
            Container(
              height: context.spacingXxl,
              width: context.spacingXxl,
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border.all(
                  color: context.colors.textSecondary.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(context.radiusS),
              ),
              child: IconButton(
                icon: Icon(
                  widget.sortOrder == SortOrder.asc
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: context.responsiveIconSize(18),
                  color: context.colors.primary,
                ),
                onPressed: () => widget.onSortOrderChanged(
                  widget.sortOrder == SortOrder.asc
                      ? SortOrder.desc
                      : SortOrder.asc,
                ),
                tooltip: widget.sortOrder == SortOrder.asc
                    ? 'A-Z / Low-High'
                    : 'Z-A / High-Low',
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDemographicsRow() {
    return Row(
      children: [
        Expanded(
          child: FilterDropdown<String?>(
            label: 'Gender',
            value: widget.selectedGender,
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('All')),
              ...widget.genders.map(
                (g) => DropdownMenuItem<String?>(value: g, child: Text(g)),
              ),
            ],
            onChanged: widget.onGenderChanged,
          ),
        ),
        SizedBox(width: context.spacingMd),
        Expanded(
          child: FilterDropdown<String?>(
            label: 'District',
            value: widget.selectedDistrict,
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('All')),
              ...widget.districts.map(
                (d) => DropdownMenuItem<String?>(value: d, child: Text(d)),
              ),
            ],
            onChanged: widget.onDistrictChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionToggle() {
    return InkWell(
      onTap: () {
        setState(() {
          _showPermissionFilters = !_showPermissionFilters;

          if (!_showPermissionFilters) {
            widget.onPermFilterChanged(PermissionFilter.all);
            widget.onCampChanged(null);
            widget.onMyfChanged(null);
            widget.onPermissionTypeChanged(PermissionType.camps);
          }
        });
      },
      borderRadius: BorderRadius.circular(context.radiusS),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.spacing(10),
          horizontal: context.spacingMd,
        ),
        decoration: BoxDecoration(
          color: _showPermissionFilters
              ? context.colors.primary.withValues(alpha: 0.05)
              : context.colors.textSecondary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(context.radiusS),
          border: Border.all(
            color: _showPermissionFilters
                ? context.colors.primary.withValues(alpha: 0.3)
                : context.colors.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.security,
              size: 18,
              color: _showPermissionFilters
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
            SizedBox(width: context.spacingSm),
            Expanded(
              child: Text(
                'Permission Filters',
                style: context.typography.bodyMedium?.copyWith(
                  fontSize: context.responsiveFontSize(13),
                  fontWeight: FontWeight.w600,
                  color: _showPermissionFilters
                      ? context.colors.primary
                      : context.colors.textSecondary,
                ),
              ),
            ),
            Icon(
              _showPermissionFilters ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: _showPermissionFilters
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionFilters(
    List<Map<String, Object>> activeItems,
    String? selectedId,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      children: [
        SizedBox(height: context.spacingMd),

        Row(
          children: [
            Expanded(
              child: PermissionTypeButton(
                label: 'Camps',
                icon: Icons.campaign,
                isSelected: widget.permissionType == PermissionType.camps,
                onTap: () {
                  if (widget.permissionType != PermissionType.camps) {
                    widget.onMyfChanged(null);
                    widget.onPermFilterChanged(PermissionFilter.all);
                  }
                  widget.onPermissionTypeChanged(PermissionType.camps);
                },
              ),
            ),
            SizedBox(width: context.spacingSm),
            Expanded(
              child: PermissionTypeButton(
                label: 'MYF Groups',
                icon: Icons.group,
                isSelected: widget.permissionType == PermissionType.myfs,
                onTap: () {
                  if (widget.permissionType != PermissionType.myfs) {
                    widget.onCampChanged(null);
                    widget.onPermFilterChanged(PermissionFilter.all);
                  }
                  widget.onPermissionTypeChanged(PermissionType.myfs);
                },
              ),
            ),
          ],
        ),

        SizedBox(height: context.spacingMd),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: FilterDropdown<String?>(
                label: widget.permissionType == PermissionType.camps
                    ? 'Camp'
                    : 'MYF Group',
                value: selectedId,
                items: activeItems.map((item) {
                  final id = item['id'] as String;
                  final title = item['title'] as String;
                  return DropdownMenuItem<String?>(
                    value: id,
                    child: Text(
                      title.length > 20
                          ? '${title.substring(0, 20)}...'
                          : title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
            SizedBox(width: context.spacingMd),
            Expanded(
              child: FilterDropdown<PermissionFilter>(
                label: 'Access',
                value: widget.permFilter,
                items: const [
                  DropdownMenuItem(
                    value: PermissionFilter.all,
                    child: Text('All'),
                  ),
                  DropdownMenuItem(
                    value: PermissionFilter.has,
                    child: Text('Has'),
                  ),
                  DropdownMenuItem(
                    value: PermissionFilter.not,
                    child: Text('Missing'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    widget.onPermFilterChanged(v);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
