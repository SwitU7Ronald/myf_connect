import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/app_user.dart';
import '../../../widgets/widgets.dart';

enum SortBy { name, phone, district, permissions }
enum SortOrder { asc, desc }
enum PermissionFilter { all, has, not }
enum PermissionType { camps, myfs } // NEW: Add permission type

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  String search = '';
  SortBy sortBy = SortBy.name;
  SortOrder sortOrder = SortOrder.asc;
  String? selectedGender;
  String? selectedDistrict;
  String? selectedCampId;
  String? selectedMyfId; // NEW: Add MYF filter
  PermissionFilter permFilter = PermissionFilter.all;
  PermissionType permissionType = PermissionType.camps; // NEW: Default to camps

  /// Set camp permission for a user
  Future<void> setCampPermission({
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
                  ? 'Camp permission granted successfully'
                  : 'Camp permission removed successfully',
            ),
            backgroundColor: MethodistTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating camp permission: $e'),
            backgroundColor: MethodistTheme.errorRed,
          ),
        );
      }
    }
  }

  /// NEW: Set MYF permission for a user
  Future<void> setMyfPermission({
    required String uid,
    required String myfId,
    required bool enabled,
  }) async {
    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(uid);
      await ref.update({
        'permissions': enabled
            ? FieldValue.arrayUnion([myfId])
            : FieldValue.arrayRemove([myfId]),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? 'MYF permission granted successfully'
                  : 'MYF permission removed successfully',
            ),
            backgroundColor: MethodistTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating MYF permission: $e'),
            backgroundColor: MethodistTheme.errorRed,
          ),
        );
      }
    }
  }

  Stream<QuerySnapshot> get campsStream =>
      FirebaseFirestore.instance.collection('camps').snapshots();

  // NEW: Add MYF stream
  Stream<QuerySnapshot> get myfsStream =>
      FirebaseFirestore.instance.collection('myfs').snapshots();

  Stream<QuerySnapshot> get usersStream =>
      FirebaseFirestore.instance.collection('users').snapshots();

  void clearFilters() {
    setState(() {
      search = '';
      sortBy = SortBy.name;
      sortOrder = SortOrder.asc;
      selectedCampId = null;
      selectedMyfId = null; // NEW
      permFilter = PermissionFilter.all;
      selectedGender = null;
      selectedDistrict = null;
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
        stream: campsStream,
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
            final data = (d.data() as Map<String, dynamic>?) ?? {};
            final title = (data['title'] as String?)?.trim();
            return {
              'id': d.id,
              'title': title == null || title.isEmpty ? d.id : title,
            };
          }).toList()
            ..sort((a, b) => (a['title'] as String)
                .toLowerCase()
                .compareTo((b['title'] as String).toLowerCase()));

          // NEW: Fetch MYF groups
          return StreamBuilder<QuerySnapshot>(
            stream: myfsStream,
            builder: (context, myfsSnap) {
              if (myfsSnap.connectionState == ConnectionState.waiting) {
                return const LoadingWidget(message: 'Loading MYF groups...');
              }
              if (myfsSnap.hasError) {
                return ErrorStateWidget(
                  title: 'Error Loading MYF Groups',
                  description: 'Failed to load MYF groups: ${myfsSnap.error}',
                  onRetry: () => setState(() {}),
                );
              }

              final myfDocs = myfsSnap.data?.docs ?? [];
              final myfs = myfDocs.map((d) {
                final data = (d.data() as Map<String, dynamic>?) ?? {};
                final title = (data['title'] as String?)?.trim();
                return {
                  'id': d.id,
                  'title': title == null || title.isEmpty ? d.id : title,
                };
              }).toList()
                ..sort((a, b) => (a['title'] as String)
                    .toLowerCase()
                    .compareTo((b['title'] as String).toLowerCase()));

              return StreamBuilder<QuerySnapshot>(
                stream: usersStream,
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
                      '${u.firstName ?? ''} ${u.lastName ?? ''}'.trim();

                  bool matchesSearch(AppUser u) {
                    if (search.isEmpty) return true;
                    final q = search.toLowerCase();
                    return fullName(u).toLowerCase().contains(q) ||
                        (u.firstName ?? '').toLowerCase().contains(q) ||
                        (u.lastName ?? '').toLowerCase().contains(q) ||
                        u.phone.toLowerCase().contains(q) ||
                        (u.district ?? '').toLowerCase().contains(q) ||
                        (u.church ?? '').toLowerCase().contains(q) ||
                        u.uid.toLowerCase().contains(q);
                  }

                  bool matchesGender(AppUser u) =>
                      selectedGender == null || u.gender == selectedGender;

                  bool matchesDistrict(AppUser u) =>
                      selectedDistrict == null || u.district == selectedDistrict;

                  bool matchesPermission(AppUser u) {
                    // Check based on selected permission type
                    final selectedId = permissionType == PermissionType.camps
                        ? selectedCampId
                        : selectedMyfId;

                    if (selectedId == null || permFilter == PermissionFilter.all) {
                      return true;
                    }
                    final has = u.permissions.contains(selectedId);
                    if (permFilter == PermissionFilter.has) return has;
                    if (permFilter == PermissionFilter.not) return !has;
                    return true;
                  }

                  List<AppUser> filtered = allUsers.where((u) {
                    return matchesSearch(u) &&
                        matchesGender(u) &&
                        matchesDistrict(u) &&
                        matchesPermission(u);
                  }).toList();

                  // Sort filtered users
                  int cmpStr(String a, String b) =>
                      a.toLowerCase().compareTo(b.toLowerCase());

                  int comparator(AppUser a, AppUser b) {
                    int r = 0;
                    switch (sortBy) {
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
                    return sortOrder == SortOrder.asc ? r : -r;
                  }

                  filtered.sort(comparator);

                  return Column(
                    children: [
                      // Filter Bar
                      FilterBar(
                        search: search,
                        onSearchChanged: (v) => setState(() => search = v),
                        sortBy: sortBy,
                        onSortByChanged: (v) => setState(() => sortBy = v),
                        sortOrder: sortOrder,
                        onSortOrderChanged: (v) => setState(() => sortOrder = v),
                        camps: camps,
                        myfs: myfs, // NEW: Pass MYF groups
                        selectedCampId: selectedCampId,
                        selectedMyfId: selectedMyfId, // NEW
                        onCampChanged: (v) => setState(() => selectedCampId = v),
                        onMyfChanged: (v) => setState(() => selectedMyfId = v), // NEW
                        permFilter: permFilter,
                        onPermFilterChanged: (v) => setState(() => permFilter = v),
                        permissionType: permissionType, // NEW
                        onPermissionTypeChanged: (v) => setState(() {
                          permissionType = v;
                          // Clear the other filter when switching types
                          if (v == PermissionType.camps) {
                            selectedMyfId = null;
                          } else {
                            selectedCampId = null;
                          }
                        }),
                        genders: genderList,
                        selectedGender: selectedGender,
                        onGenderChanged: (v) => setState(() => selectedGender = v),
                        districts: districtList,
                        selectedDistrict: selectedDistrict,
                        onDistrictChanged: (v) => setState(() => selectedDistrict = v),
                        onClear: clearFilters,
                      ),

                      // Users List
                      if (filtered.isEmpty)
                        const Expanded(
                          child: EmptyStateWidget(
                            icon: Icons.people_outline,
                            title: 'No Users Found',
                            description:
                            'No users match your current filters. Try adjusting your search criteria.',
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
                                    type: perms.isEmpty
                                        ? StatusType.neutral
                                        : StatusType.info,
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
                                          UserDetailRow('District:', user.district ?? 'Not specified'),
                                          UserDetailRow('Church:', user.church ?? 'Not specified'),
                                          UserDetailRow('Gender:', user.gender ?? 'Not specified'),
                                          SizedBox(height: MethodistTheme.spacingM),

                                          // Camp Permissions Section
                                          if (camps.isEmpty)
                                            _buildNoItemsAvailable(
                                              'Camps',
                                              'No camps are available for permission assignment.',
                                              Icons.campaign_outlined,
                                            )
                                          else
                                            _buildPermissionsSection(
                                              title: 'Camp Permissions',
                                              items: camps,
                                              userPermissions: perms,
                                              onPermissionChanged: (id, enabled) {
                                                setCampPermission(
                                                  uid: user.uid,
                                                  campId: id,
                                                  enabled: enabled,
                                                );
                                              },
                                            ),

                                          SizedBox(height: MethodistTheme.spacingM),

                                          // NEW: MYF Permissions Section
                                          if (myfs.isEmpty)
                                            _buildNoItemsAvailable(
                                              'MYF Groups',
                                              'No MYF groups are available for permission assignment.',
                                              Icons.group_outlined,
                                            )
                                          else
                                            _buildPermissionsSection(
                                              title: 'MYF Permissions',
                                              items: myfs,
                                              userPermissions: perms,
                                              onPermissionChanged: (id, enabled) {
                                                setMyfPermission(
                                                  uid: user.uid,
                                                  myfId: id,
                                                  enabled: enabled,
                                                );
                                              },
                                            ),
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
          );
        },
      ),
    );
  }

  // NEW: Helper method to build "no items available" message
  Widget _buildNoItemsAvailable(String itemType, String message, IconData icon) {
    return Container(
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
            icon,
            color: MethodistTheme.mediumGray,
            size: 40,
          ),
          SizedBox(width: MethodistTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No $itemType Available',
                  style: MethodistTheme.titleSmall,
                ),
                Text(
                  message,
                  style: MethodistTheme.bodySmall.copyWith(
                    color: MethodistTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Helper method to build permissions section
  Widget _buildPermissionsSection({
    required String title,
    required List<Map<String, Object>> items,
    required List<String> userPermissions,
    required Function(String id, bool enabled) onPermissionChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
            children: items.map((item) {
              final itemId = item['id'] as String;
              final itemTitle = item['title'] as String;
              final selected = userPermissions.contains(itemId);

              return PermissionChip(
                text: itemTitle,
                isSelected: selected,
                onChanged: (isSelected) {
                  onPermissionChanged(itemId, isSelected);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// Rest of the classes remain the same...
class UserDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const UserDetailRow(this.label, this.value, {super.key});

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
              label,
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

class FilterBar extends StatelessWidget {
  final String search;
  final ValueChanged<String> onSearchChanged;
  final SortBy sortBy;
  final ValueChanged<SortBy> onSortByChanged;
  final SortOrder sortOrder;
  final ValueChanged<SortOrder> onSortOrderChanged;
  final List<Map<String, Object>> camps;
  final List<Map<String, Object>> myfs; // NEW
  final String? selectedCampId;
  final String? selectedMyfId; // NEW
  final ValueChanged<String?> onCampChanged;
  final ValueChanged<String?> onMyfChanged; // NEW
  final PermissionFilter permFilter;
  final ValueChanged<PermissionFilter> onPermFilterChanged;
  final PermissionType permissionType; // NEW
  final ValueChanged<PermissionType> onPermissionTypeChanged; // NEW
  final List<String> genders;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final List<String> districts;
  final String? selectedDistrict;
  final ValueChanged<String?> onDistrictChanged;
  final VoidCallback onClear;

  const FilterBar({
    super.key,
    required this.search,
    required this.onSearchChanged,
    required this.sortBy,
    required this.onSortByChanged,
    required this.sortOrder,
    required this.onSortOrderChanged,
    required this.camps,
    required this.myfs, // NEW
    required this.selectedCampId,
    required this.selectedMyfId, // NEW
    required this.onCampChanged,
    required this.onMyfChanged, // NEW
    required this.permFilter,
    required this.onPermFilterChanged,
    required this.permissionType, // NEW
    required this.onPermissionTypeChanged, // NEW
    required this.genders,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.districts,
    required this.selectedDistrict,
    required this.onDistrictChanged,
    required this.onClear,
  });

  String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    // Get the currently active items based on permission type
    final activeItems = permissionType == PermissionType.camps ? camps : myfs;
    final selectedId = permissionType == PermissionType.camps ? selectedCampId : selectedMyfId;
    final onChanged = permissionType == PermissionType.camps ? onCampChanged : onMyfChanged;

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

          // Search Field
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

          // Row 1 - Sort
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SortBy>(
                  isExpanded: true,
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
                  isExpanded: true,
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

          // NEW: Row 2 - Permission Type Toggle
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<PermissionType>(
                  isExpanded: true,
                  value: permissionType,
                  onChanged: (v) => v == null ? null : onPermissionTypeChanged(v),
                  decoration: InputDecoration(
                    labelText: 'Permission Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: PermissionType.camps, child: Text('Camps')),
                    DropdownMenuItem(value: PermissionType.myfs, child: Text('MYF Groups')),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: MethodistTheme.spacingS),

          // Row 3 - Camp/MYF Selection and Filter
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedId,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    labelText: permissionType == PermissionType.camps ? 'Camp' : 'MYF Group',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...activeItems.map((item) {
                      final id = item['id'] as String;
                      final title = truncateText(item['title'] as String, 25);
                      return DropdownMenuItem(value: id, child: Text(title));
                    }),
                  ],
                ),
              ),
              SizedBox(width: MethodistTheme.spacingS),
              Expanded(
                child: DropdownButtonFormField<PermissionFilter>(
                  isExpanded: true,
                  value: permFilter,
                  onChanged: (v) => v == null ? null : onPermFilterChanged(v),
                  decoration: InputDecoration(
                    labelText: 'Filter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: PermissionFilter.all, child: Text('All')),
                    DropdownMenuItem(value: PermissionFilter.has, child: Text('Has')),
                    DropdownMenuItem(value: PermissionFilter.not, child: Text('Not')),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: MethodistTheme.spacingS),

          // Row 4 - Gender and District
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
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
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...genders.map((g) => DropdownMenuItem(value: g, child: Text(g))),
                  ],
                ),
              ),
              SizedBox(width: MethodistTheme.spacingS),
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
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
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...districts.map((d) {
                      final truncated = truncateText(d, 20);
                      return DropdownMenuItem(value: d, child: Text(truncated));
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
