import 'package:flutter/material.dart';
import 'package:myf_connect/core/widgets/widgets.dart';

import 'package:myf_connect/features/admin/presentation/widgets/users_manage/user_filter_enums.dart';
import 'package:myf_connect/features/admin/presentation/widgets/users_manage/filter_components.dart';

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
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: MyfTheme.paddingM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildSortRow(),
          const SizedBox(height: 16),
          _buildDemographicsRow(),
          const SizedBox(height: 12),
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
        const Text(
          'Filters & Search',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: MyfTheme.primaryRed,
          ),
        ),
        TextButton.icon(
          onPressed: widget.onClear,
          icon: const Icon(Icons.clear_all, size: 16),
          label: const Text('Clear All'),
          style: TextButton.styleFrom(
            foregroundColor: MyfTheme.primaryRed,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        hintStyle: const TextStyle(fontSize: 14, color: MyfTheme.mediumGray),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: MyfTheme.mediumGray,
        ),
        suffixIcon: widget.searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  widget.searchController.clear();
                  widget.searchFocus.unfocus();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: MyfTheme.mediumGray.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: MyfTheme.mediumGray.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: MyfTheme.primaryRed, width: 1.5),
        ),
        filled: true,
        fillColor: MyfTheme.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        isDense: true,
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => widget.searchFocus.unfocus(),
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildSortRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort By',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: MyfTheme.mediumGray,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: MyfTheme.white,
                  border: Border.all(
                    color: MyfTheme.mediumGray.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
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
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  isExpanded: true,
                  menuMaxHeight: 250,
                  style: const TextStyle(
                    fontSize: 14,
                    color: MyfTheme.darkGray,
                  ),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: MyfTheme.mediumGray,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: MyfTheme.white,
                border: Border.all(
                  color: MyfTheme.mediumGray.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  widget.sortOrder == SortOrder.asc
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 18,
                  color: MyfTheme.primaryRed,
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
        const SizedBox(width: 12),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: _showPermissionFilters
              ? MyfTheme.primaryRed.withValues(alpha: 0.05)
              : MyfTheme.mediumGray.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _showPermissionFilters
                ? MyfTheme.primaryRed.withValues(alpha: 0.3)
                : MyfTheme.mediumGray.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.security,
              size: 18,
              color: _showPermissionFilters
                  ? MyfTheme.primaryRed
                  : MyfTheme.mediumGray,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Permission Filters',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _showPermissionFilters
                      ? MyfTheme.primaryRed
                      : MyfTheme.mediumGray,
                ),
              ),
            ),
            Icon(
              _showPermissionFilters ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: _showPermissionFilters
                  ? MyfTheme.primaryRed
                  : MyfTheme.mediumGray,
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
        const SizedBox(height: 12),

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
            const SizedBox(width: 8),
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

        const SizedBox(height: 12),

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
            const SizedBox(width: 12),
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
