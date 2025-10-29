import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/app_user.dart';
import '../../../widgets/widgets.dart';

enum SortBy { name, phone, district, permissions }
enum SortOrder { asc, desc }
enum PermissionFilter { all, has, not }

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  String _search = '';
  SortBy _sortBy = SortBy.name;
  SortOrder _sortOrder = SortOrder.asc;
  String? _selectedGender;
  String? _selectedDistrict;
  String? _selectedCampId;
  PermissionFilter _permFilter = PermissionFilter.all;

  Future<void> _setCampPermission({
    required String uid,
    required String campId,
    required bool enabled,
  }) async {
    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(uid);
      await ref.update({
        'permissions': enabled
            ? FieldValue.arrayUnion([campId])
            : FieldValue.arrayRemove([campId]),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                enabled
                    ? 'Permission granted successfully'
                    : 'Permission removed successfully'
            ),
            backgroundColor: MethodistTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating permission: $e'),
            backgroundColor: MethodistTheme.errorRed,
          ),
        );
      }
    }
  }

  Stream<QuerySnapshot> get _campsStream =>
      FirebaseFirestore.instance.collection('camps').snapshots();

  Stream<QuerySnapshot> get _usersStream =>
      FirebaseFirestore.instance.collection('users').snapshots();

  void _clearFilters() {
    setState(() {
      _search = '';
      _sortBy = SortBy.name;
      _sortOrder = SortOrder.asc;
      _selectedCampId = null;
      _permFilter = PermissionFilter.all;
      _selectedGender = null;
      _selectedDistrict = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MethodistTheme.lightGray,
      appBar: AppBar(
        title: const Text('Users Management'),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _campsStream,
        builder: (context, campsSnap) {
          if (campsSnap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading camps...');
          }

          if (campsSnap.hasError) {
            return ErrorStateWidget(
              title: 'Error Loading Camps',
              description: 'Failed to load camps: ${campsSnap.error}',
              onRetry: () => setState(() {}),
            );
          }

          final campDocs = campsSnap.data?.docs ?? [];
          final camps = campDocs.map((d) {
            final data = d.data() as Map<String, dynamic>? ?? {};
            final title = (data['title'] as String?)?.trim();
            return {
              'id': d.id,
              'title': (title == null || title.isEmpty) ? d.id : title,
            };
          }).toList()
            ..sort(
                  (a, b) => (a['title'] as String).toLowerCase().compareTo(
                (b['title'] as String).toLowerCase(),
              ),
            );

          return StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder: (context, usersSnap) {
              if (usersSnap.connectionState == ConnectionState.waiting) {
                return const LoadingWidget(message: 'Loading users...');
              }

              if (usersSnap.hasError) {
                return ErrorStateWidget(
                  title: 'Error Loading Users',
                  description: 'Failed to load users: ${usersSnap.error}',
                  onRetry: () => setState(() {}),
                );
              }

              final allUsers = usersSnap.data?.docs
                  .map(
                    (d) => AppUser.fromMap(
                  d.id,
                  d.data() as Map<String, dynamic>,
                ),
              )
                  .toList() ??
                  [];

              final districts = <String>{};
              final genders = <String>{};
              for (final u in allUsers) {
                if ((u.district ?? '').trim().isNotEmpty) {
                  districts.add(u.district!.trim());
                }
                if ((u.gender ?? '').trim().isNotEmpty) {
                  genders.add(u.gender!.trim());
                }
              }

              final districtList = districts.toList()
                ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
              final genderList = genders.toList()
                ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

              // Filter and sort logic
              String fullName(AppUser u) =>
                  ('${u.firstName ?? ''} ${u.lastName ?? ''}').trim();

              bool matchesSearch(AppUser u) {
                if (_search.isEmpty) return true;
                final q = _search.toLowerCase();
                return fullName(u).toLowerCase().contains(q) ||
                    (u.firstName ?? '').toLowerCase().contains(q) ||
                    (u.lastName ?? '').toLowerCase().contains(q) ||
                    u.phone.toLowerCase().contains(q) ||
                    (u.district ?? '').toLowerCase().contains(q) ||
                    (u.church ?? '').toLowerCase().contains(q) ||
                    u.uid.toLowerCase().contains(q);
              }

              bool matchesGender(AppUser u) =>
                  _selectedGender == null || u.gender == _selectedGender;

              bool matchesDistrict(AppUser u) =>
                  _selectedDistrict == null || u.district == _selectedDistrict;

              bool matchesCampPermission(AppUser u) {
                if (_selectedCampId == null || _permFilter == PermissionFilter.all) {
                  return true;
                }
                final has = u.permissions.contains(_selectedCampId);
                if (_permFilter == PermissionFilter.has) return has;
                if (_permFilter == PermissionFilter.not) return !has;
                return true;
              }

              List<AppUser> filtered = allUsers.where((u) {
                return matchesSearch(u) &&
                    matchesGender(u) &&
                    matchesDistrict(u) &&
                    matchesCampPermission(u);
              }).toList();

              // Sort filtered users
              int cmpStr(String a, String b) =>
                  a.toLowerCase().compareTo(b.toLowerCase());

              int comparator(AppUser a, AppUser b) {
                int r = 0;
                switch (_sortBy) {
                  case SortBy.name:
                    r = cmpStr(fullName(a), fullName(b));
                    break;
                  case SortBy.phone:
                    r = cmpStr(a.phone, b.phone);
                    break;
                  case SortBy.district:
                    r = cmpStr(a.district ?? '', b.district ?? '');
                    break;
                  case SortBy.permissions:
                    r = a.permissions.length.compareTo(b.permissions.length);
                    break;
                }
                return _sortOrder == SortOrder.asc ? r : -r;
              }

              filtered.sort(comparator);

              return Column(
                children: [
                  // Filter Bar
                  _FilterBar(
                    search: _search,
                    onSearchChanged: (v) => setState(() => _search = v),
                    sortBy: _sortBy,
                    onSortByChanged: (v) => setState(() => _sortBy = v),
                    sortOrder: _sortOrder,
                    onSortOrderChanged: (v) => setState(() => _sortOrder = v),
                    camps: camps,
                    selectedCampId: _selectedCampId,
                    onCampChanged: (v) => setState(() => _selectedCampId = v),
                    permFilter: _permFilter,
                    onPermFilterChanged: (v) => setState(() => _permFilter = v),
                    genders: genderList,
                    selectedGender: _selectedGender,
                    onGenderChanged: (v) => setState(() => _selectedGender = v),
                    districts: districtList,
                    selectedDistrict: _selectedDistrict,
                    onDistrictChanged: (v) => setState(() => _selectedDistrict = v),
                    onClear: _clearFilters,
                  ),

                  // Users List
                  if (filtered.isEmpty)
                    const Expanded(
                      child: EmptyStateWidget(
                        icon: Icons.people_outline,
                        title: 'No Users Found',
                        description: 'No users match your current filters. Try adjusting your search criteria.',
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: MethodistTheme.paddingM,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          final name = fullName(user);
                          final perms = user.permissions;

                          return MethodistCard(
                            margin: EdgeInsets.only(bottom: MethodistTheme.spacingM),
                            child: ExpansionTile(
                              title: Text(
                                name.isEmpty ? 'Unnamed user' : name,
                                style: MethodistTheme.titleMedium,
                              ),
                              subtitle: Text(
                                user.phone.isEmpty ? 'No phone' : user.phone,
                                style: MethodistTheme.bodySmall.copyWith(
                                  color: MethodistTheme.mediumGray,
                                ),
                              ),
                              trailing: StatusBadge(
                                text: '${perms.length}',
                                type: perms.isEmpty ? StatusType.neutral : StatusType.info,
                                isSmall: true,
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: MethodistTheme.paddingM,
                                  decoration: BoxDecoration(
                                    color: MethodistTheme.lightGray,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(MethodistTheme.radiusL),
                                      bottomRight: Radius.circular(MethodistTheme.radiusL),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // User Details
                                      Text(
                                        'User Details',
                                        style: MethodistTheme.titleSmall.copyWith(
                                          color: MethodistTheme.primaryRed,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: MethodistTheme.spacingS),

                                      _UserDetailRow('District', user.district ?? 'Not specified'),
                                      _UserDetailRow('Church', user.church ?? 'Not specified'),
                                      _UserDetailRow('Gender', user.gender ?? 'Not specified'),

                                      SizedBox(height: MethodistTheme.spacingM),

                                      if (camps.isEmpty)
                                        Container(
                                          padding: MethodistTheme.paddingM,
                                          decoration: BoxDecoration(
                                            color: MethodistTheme.white,
                                            borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
                                            border: Border.all(
                                              color: MethodistTheme.mediumGray.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.campaign_outlined,
                                                color: MethodistTheme.mediumGray,
                                                size: 40,
                                              ),
                                              SizedBox(width: MethodistTheme.spacingM),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'No Camps Available',
                                                      style: MethodistTheme.titleSmall,
                                                    ),
                                                    Text(
                                                      'No camps are available for permission assignment.',
                                                      style: MethodistTheme.bodySmall.copyWith(
                                                        color: MethodistTheme.mediumGray,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else ...[
                                        Text(
                                          'Camp Permissions',
                                          style: MethodistTheme.titleSmall.copyWith(
                                            color: MethodistTheme.primaryRed,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: MethodistTheme.spacingS),
                                        Container(
                                          padding: MethodistTheme.paddingM,
                                          decoration: BoxDecoration(
                                            color: MethodistTheme.white,
                                            borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
                                            border: Border.all(
                                              color: MethodistTheme.mediumGray.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Wrap(
                                            spacing: MethodistTheme.spacingS,
                                            runSpacing: MethodistTheme.spacingS,
                                            children: camps.map((camp) {
                                              final campId = camp['id'] as String;
                                              final campTitle = camp['title'] as String;
                                              final selected = perms.contains(campId);

                                              return PermissionChip(
                                                text: campTitle,
                                                isSelected: selected,
                                                onChanged: (isSelected) {
                                                  _setCampPermission(
                                                    uid: user.uid,
                                                    campId: campId,
                                                    enabled: isSelected,
                                                  );
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _UserDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _UserDetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MethodistTheme.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: MethodistTheme.bodySmall.copyWith(
                color: MethodistTheme.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: MethodistTheme.bodySmall.copyWith(
                color: MethodistTheme.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String search;
  final ValueChanged<String> onSearchChanged;
  final SortBy sortBy;
  final ValueChanged<SortBy> onSortByChanged;
  final SortOrder sortOrder;
  final ValueChanged<SortOrder> onSortOrderChanged;
  final List<Map<String, Object>> camps;
  final String? selectedCampId;
  final ValueChanged<String?> onCampChanged;
  final PermissionFilter permFilter;
  final ValueChanged<PermissionFilter> onPermFilterChanged;
  final List<String> genders;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final List<String> districts;
  final String? selectedDistrict;
  final ValueChanged<String?> onDistrictChanged;
  final VoidCallback onClear;

  const _FilterBar({
    required this.search,
    required this.onSearchChanged,
    required this.sortBy,
    required this.onSortByChanged,
    required this.sortOrder,
    required this.onSortOrderChanged,
    required this.camps,
    required this.selectedCampId,
    required this.onCampChanged,
    required this.permFilter,
    required this.onPermFilterChanged,
    required this.genders,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.districts,
    required this.selectedDistrict,
    required this.onDistrictChanged,
    required this.onClear,
  });

  // Helper method to truncate text
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return MethodistCard(
      margin: MethodistTheme.paddingM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filters & Search',
            style: MethodistTheme.titleMedium.copyWith(
              color: MethodistTheme.primaryRed,
            ),
          ),
          SizedBox(height: MethodistTheme.spacingS),

          // Search Field - FIXED WIDTH
          SizedBox(
            height: 50,
            child: TextFormField(
              initialValue: search,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Name, phone, district...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
            ),
          ),

          SizedBox(height: MethodistTheme.spacingS),

          // FIXED: Properly constrained dropdowns
          Column(
            children: [
              // Row 1 - Sort (FIXED OVERFLOW)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<SortBy>(
                      isExpanded: true, // FIXED: Ensures dropdown uses full width
                      value: sortBy,
                      onChanged: (v) => v == null ? null : onSortByChanged(v),
                      decoration: InputDecoration(
                        labelText: 'Sort',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: SortBy.name, child: Text('Name')),
                        DropdownMenuItem(value: SortBy.phone, child: Text('Phone')),
                        DropdownMenuItem(value: SortBy.district, child: Text('District')),
                        DropdownMenuItem(value: SortBy.permissions, child: Text('Permissions')),
                      ],
                    ),
                  ),
                  SizedBox(width: MethodistTheme.spacingS),
                  Expanded(
                    child: DropdownButtonFormField<SortOrder>(
                      isExpanded: true, // FIXED
                      value: sortOrder,
                      onChanged: (v) => v == null ? null : onSortOrderChanged(v),
                      decoration: InputDecoration(
                        labelText: 'Order',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: SortOrder.asc, child: Text('A-Z')),
                        DropdownMenuItem(value: SortOrder.desc, child: Text('Z-A')),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: MethodistTheme.spacingS),

              // Row 2 - Camp & Permission (FIXED OVERFLOW)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      isExpanded: true, // FIXED
                      value: selectedCampId,
                      onChanged: onCampChanged,
                      decoration: InputDecoration(
                        labelText: 'Camp',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            'All',
                            overflow: TextOverflow.ellipsis, // FIXED
                          ),
                        ),
                        ...camps.map(
                              (c) => DropdownMenuItem<String?>(
                            value: c['id'] as String,
                            child: Text(
                              _truncateText(c['title'] as String, 12), // FIXED: Truncate long text
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: MethodistTheme.spacingS),
                  Expanded(
                    child: DropdownButtonFormField<PermissionFilter>(
                      isExpanded: true, // FIXED
                      value: permFilter,
                      onChanged: (v) => v == null ? null : onPermFilterChanged(v),
                      decoration: InputDecoration(
                        labelText: 'Permission',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: PermissionFilter.all,
                          child: Text('All', overflow: TextOverflow.ellipsis), // FIXED
                        ),
                        DropdownMenuItem(
                          value: PermissionFilter.has,
                          child: Text('Has', overflow: TextOverflow.ellipsis), // FIXED
                        ),
                        DropdownMenuItem(
                          value: PermissionFilter.not,
                          child: Text('None', overflow: TextOverflow.ellipsis), // FIXED
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: MethodistTheme.spacingS),

              // Row 3 - Gender & District (FIXED OVERFLOW)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      isExpanded: true, // FIXED
                      value: selectedGender,
                      onChanged: onGenderChanged,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All', overflow: TextOverflow.ellipsis), // FIXED
                        ),
                        ...genders.map(
                              (g) => DropdownMenuItem<String?>(
                            value: g,
                            child: Text(
                              _truncateText(g, 8), // FIXED: Truncate
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: MethodistTheme.spacingS),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      isExpanded: true, // FIXED
                      value: selectedDistrict,
                      onChanged: onDistrictChanged,
                      decoration: InputDecoration(
                        labelText: 'District',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All', overflow: TextOverflow.ellipsis), // FIXED
                        ),
                        ...districts.map(
                              (d) => DropdownMenuItem<String?>(
                            value: d,
                            child: Text(
                              _truncateText(d, 10), // FIXED: Truncate long district names
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: MethodistTheme.spacingM),

          // Reset Button
          Center(
            child: SizedBox(
              height: 35,
              child: PrimaryButton.secondary(
                label: 'Reset',
                onPressed: onClear,
                icon: Icons.refresh,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

