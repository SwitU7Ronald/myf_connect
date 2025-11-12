import 'package:flutter/material.dart';
import './widgets.dart';

/// Enums for User Filter Bar
enum SortBy { name, phone, district, permissions }
enum SortOrder { asc, desc }
enum PermissionFilter { all, has, not }
enum PermissionType { camps, myfs }

/// Production-ready User Filter Bar Widget
/// Collapsible permission filters with clean, minimal design
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

    return MethodistCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
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
            color: MethodistTheme.primaryRed,
          ),
        ),
        TextButton.icon(
          onPressed: widget.onClear,
          icon: const Icon(Icons.clear_all, size: 16),
          label: const Text('Clear All'),
          style: TextButton.styleFrom(
            foregroundColor: MethodistTheme.primaryRed,
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
        hintStyle: const TextStyle(
            fontSize: 14, color: MethodistTheme.mediumGray),
        prefixIcon: const Icon(
            Icons.search, size: 20, color: MethodistTheme.mediumGray),
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
              color: MethodistTheme.mediumGray.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: MethodistTheme.mediumGray.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: MethodistTheme.primaryRed, width: 1.5),
        ),
        filled: true,
        fillColor: MethodistTheme.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12),
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
            color: MethodistTheme.mediumGray,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: MethodistTheme.white,
                  border: Border.all(
                    color: MethodistTheme.mediumGray.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<SortBy>(
                  value: widget.sortBy,
                  items: const [
                    DropdownMenuItem(value: SortBy.name, child: Text('Name')),
                    DropdownMenuItem(value: SortBy.phone, child: Text('Phone')),
                    DropdownMenuItem(
                        value: SortBy.district, child: Text('District')),
                    DropdownMenuItem(
                        value: SortBy.permissions, child: Text('Permissions')),
                  ],
                  onChanged: (v) =>
                  v != null
                      ? widget.onSortByChanged(v)
                      : null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  isExpanded: true,
                  menuMaxHeight: 250,
                  style: const TextStyle(
                      fontSize: 14, color: MethodistTheme.darkGray),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: MethodistTheme.mediumGray,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: MethodistTheme.white,
                border: Border.all(
                  color: MethodistTheme.mediumGray.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  widget.sortOrder == SortOrder.asc
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 18,
                  color: MethodistTheme.primaryRed,
                ),
                onPressed: () =>
                    widget.onSortOrderChanged(
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
          child: _FilterDropdown<String?>(
            label: 'Gender',
            value: widget.selectedGender,
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('All')),
              ...widget.genders.map((g) =>
                  DropdownMenuItem<String?>(value: g, child: Text(g))),
            ],
            onChanged: widget.onGenderChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FilterDropdown<String?>(
            label: 'District',
            value: widget.selectedDistrict,
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('All')),
              ...widget.districts.map((d) =>
                  DropdownMenuItem<String?>(value: d, child: Text(d))),
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

          // ✅ NEW: Clear permission filters when collapsing
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
              ? MethodistTheme.primaryRed.withValues(alpha: 0.05)
              : MethodistTheme.mediumGray.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _showPermissionFilters
                ? MethodistTheme.primaryRed.withValues(alpha: 0.3)
                : MethodistTheme.mediumGray.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.security,
              size: 18,
              color: _showPermissionFilters
                  ? MethodistTheme.primaryRed
                  : MethodistTheme.mediumGray,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Permission Filters',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _showPermissionFilters
                      ? MethodistTheme.primaryRed
                      : MethodistTheme.mediumGray,
                ),
              ),
            ),
            Icon(
              _showPermissionFilters ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: _showPermissionFilters
                  ? MethodistTheme.primaryRed
                  : MethodistTheme.mediumGray,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionFilters(List<Map<String, Object>> activeItems,
      String? selectedId,
      ValueChanged<String?> onChanged,) {
    return Column(
      children: [
        const SizedBox(height: 12),

        // Permission Type Toggle Buttons with Clear Logic
        Row(
          children: [
            Expanded(
              child: _PermissionTypeButton(
                label: 'Camps',
                icon: Icons.campaign,
                isSelected: widget.permissionType == PermissionType.camps,
                onTap: () {
                  // ✅ NEW: Clear MYF filter when switching to Camps
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
              child: _PermissionTypeButton(
                label: 'MYF Groups',
                icon: Icons.group,
                isSelected: widget.permissionType == PermissionType.myfs,
                onTap: () {
                  // ✅ NEW: Clear Camp filter when switching to MYF
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

        // Permission Dropdowns
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _FilterDropdown<String?>(
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
              child: _FilterDropdown<PermissionFilter>(
                label: 'Access',
                value: widget.permFilter,
                items: const [
                  DropdownMenuItem(
                      value: PermissionFilter.all, child: Text('All')),
                  DropdownMenuItem(
                      value: PermissionFilter.has, child: Text('Has')),
                  DropdownMenuItem(
                      value: PermissionFilter.not, child: Text('Missing')),
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

// ========== REUSABLE COMPONENTS ==========

class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: MethodistTheme.mediumGray,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: MethodistTheme.white,
            border: Border.all(color: MethodistTheme.mediumGray.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            isExpanded: true,
            menuMaxHeight: 250,
            style: const TextStyle(fontSize: 14, color: MethodistTheme.darkGray),
            icon: const Icon(Icons.arrow_drop_down, size: 20, color: MethodistTheme.mediumGray),
          ),
        ),
      ],
    );
  }
}

class _PermissionTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PermissionTypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? MethodistTheme.primaryRed : MethodistTheme.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? MethodistTheme.primaryRed
                : MethodistTheme.mediumGray.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? MethodistTheme.white : MethodistTheme.mediumGray,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? MethodistTheme.white : MethodistTheme.darkGray,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
