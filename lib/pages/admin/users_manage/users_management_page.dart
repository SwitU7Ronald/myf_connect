import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/app_user.dart';
import '../../../widgets/widgets.dart';
import 'dart:async';

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
  String? _selectedMyfId;
  PermissionFilter _permFilter = PermissionFilter.all;
  PermissionType _permissionType = PermissionType.camps;

  bool _showFilters = true;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  List<Map<String, Object>> _campsCache = [];
  List<Map<String, Object>> _myfsCache = [];
  List<AppUser> _usersCache = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted) {
        setState(() {
          _search = _searchController.text.trim();
        });
      }
    });
  }

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
        MethodistTheme.showSuccessSnackBar(
          context,
          enabled ? 'Camp permission granted' : 'Camp permission removed',
        );
      }
    } catch (e) {
      debugPrint('Error updating camp permission: $e');
      if (mounted) {
        MethodistTheme.showErrorSnackBar(
          context,
          'Failed to update camp permission',
        );
      }
    }
  }

  Future<void> _setMyfPermission({
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
        MethodistTheme.showSuccessSnackBar(
          context,
          enabled ? 'MYF permission granted' : 'MYF permission removed',
        );
      }
    } catch (e) {
      debugPrint('Error updating MYF permission: $e');
      if (mounted) {
        MethodistTheme.showErrorSnackBar(
          context,
          'Failed to update MYF permission',
        );
      }
    }
  }

  Stream<QuerySnapshot> get _campsStream =>
      FirebaseFirestore.instance.collection('camps').snapshots();

  Stream<QuerySnapshot> get _myfsStream =>
      FirebaseFirestore.instance.collection('myfs').snapshots();

  Stream<QuerySnapshot> get _usersStream =>
      FirebaseFirestore.instance.collection('users').snapshots();

  void _clearFilters() {
    _searchFocus.unfocus();

    setState(() {
      _searchController.clear();
      _search = '';
      _sortBy = SortBy.name;
      _sortOrder = SortOrder.asc;
      _selectedCampId = null;
      _selectedMyfId = null;
      _permFilter = PermissionFilter.all;
      _selectedGender = null;
      _selectedDistrict = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: MethodistTheme.lightGray,
        appBar: _buildAppBar(),
        body: StreamBuilder<QuerySnapshot>(
          stream: _campsStream,
          builder: (context, campsSnap) {
            if (campsSnap.hasError) {
              return _buildErrorState(
                'Error Loading Camps',
                'Failed to load camps data. Check your connection.',
              );
            }

            if (campsSnap.hasData) {
              _campsCache = _processCollection(campsSnap.data!.docs);
            }

            return StreamBuilder<QuerySnapshot>(
              stream: _myfsStream,
              builder: (context, myfsSnap) {
                if (myfsSnap.hasError) {
                  return _buildErrorState(
                    'Error Loading MYF Groups',
                    'Failed to load MYF groups data. Check your connection.',
                  );
                }

                if (myfsSnap.hasData) {
                  _myfsCache = _processCollection(myfsSnap.data!.docs);
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: _usersStream,
                  builder: (context, usersSnap) {
                    if (usersSnap.connectionState == ConnectionState.waiting &&
                        _usersCache.isEmpty) {
                      return const LoadingWidget(message: 'Loading users...');
                    }

                    if (usersSnap.hasError) {
                      return _buildErrorState(
                        'Error Loading Users',
                        'Failed to load users data. Please try again.',
                      );
                    }

                    if (usersSnap.hasData) {
                      _usersCache = usersSnap.data!.docs
                          .map(
                            (d) => AppUser.fromMap(
                              d.id,
                              d.data() as Map<String, dynamic>,
                            ),
                          )
                          .toList();
                    }

                    final (districts, genders) = _extractFilters(_usersCache);
                    final filtered = _applyFilters(_usersCache);

                    return Column(
                      children: [
                        _buildStatsCard(_usersCache.length, filtered.length),

                        if (_showFilters)
                          UserFilterBar(
                            searchController: _searchController,
                            searchFocus: _searchFocus,
                            sortBy: _sortBy,
                            onSortByChanged: (v) {
                              _searchFocus.unfocus();
                              setState(() => _sortBy = v);
                            },
                            sortOrder: _sortOrder,
                            onSortOrderChanged: (v) {
                              _searchFocus.unfocus();
                              setState(() => _sortOrder = v);
                            },
                            camps: _campsCache,
                            myfs: _myfsCache,
                            selectedCampId: _selectedCampId,
                            selectedMyfId: _selectedMyfId,
                            onCampChanged: (v) {
                              _searchFocus.unfocus();
                              setState(() => _selectedCampId = v);
                            },
                            onMyfChanged: (v) {
                              _searchFocus.unfocus();
                              setState(() => _selectedMyfId = v);
                            },
                            permFilter: _permFilter,
                            onPermFilterChanged: (v) {
                              _searchFocus.unfocus();
                              setState(() => _permFilter = v);
                            },
                            permissionType: _permissionType,
                            onPermissionTypeChanged: (v) {
                              _searchFocus.unfocus();
                              setState(() => _permissionType = v);
                            },
                            genders: genders,
                            selectedGender: _selectedGender,
                            onGenderChanged: (v) {
                              _searchFocus.unfocus();
                              setState(() => _selectedGender = v);
                            },
                            districts: districts,
                            selectedDistrict: _selectedDistrict,
                            onDistrictChanged: (v) {
                              _searchFocus.unfocus();
                              setState(() => _selectedDistrict = v);
                            },
                            onClear: _clearFilters,
                          ),

                        Expanded(
                          child: filtered.isEmpty
                              ? _buildEmptyState()
                              : _buildUserList(
                                  filtered,
                                  _campsCache,
                                  _myfsCache,
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Users Management',
        style: context.responsiveHeadlineSmall.copyWith(
          color: MethodistTheme.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: MethodistTheme.primaryRed,
      foregroundColor: MethodistTheme.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
          tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
          onPressed: () {
            _searchFocus.unfocus();
            setState(() => _showFilters = !_showFilters);
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () {
            _searchFocus.unfocus();
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildStatsCard(int total, int filtered) {
    final hasFilters =
        _search.isNotEmpty ||
        _selectedGender != null ||
        _selectedDistrict != null ||
        _selectedCampId != null ||
        _selectedMyfId != null ||
        _permFilter != PermissionFilter.all;

    return MethodistCard(
      margin: context.responsivePadding(horizontal: 16, vertical: 8),
      padding: context.responsivePadding(all: 16),
      color: MethodistTheme.primaryRed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Users',
                style: context.responsiveBodySmall.copyWith(
                  color: MethodistTheme.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '$total',
                style: context.responsiveHeadlineMedium.copyWith(
                  color: MethodistTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (hasFilters)
            Container(
              padding: context.responsivePadding(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MethodistTheme.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(
                  context.responsiveRadius(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    color: MethodistTheme.white,
                    size: context.responsiveIconSize(16),
                  ),
                  SizedBox(width: context.spacing(4)),
                  Text(
                    'Filtered: $filtered',
                    style: context.responsiveBodyMedium.copyWith(
                      color: MethodistTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserList(
    List<AppUser> users,
    List<Map<String, Object>> camps,
    List<Map<String, Object>> myfs,
  ) {
    return ListView.separated(
      controller: _scrollController,
      padding: context.responsivePadding(all: 16),
      itemCount: users.length,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      separatorBuilder: (context, index) =>
          SizedBox(height: context.spacing(12)),
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user, camps, myfs);
      },
    );
  }

  Widget _buildUserCard(
    AppUser user,
    List<Map<String, Object>> camps,
    List<Map<String, Object>> myfs,
  ) {
    final name = _fullName(user);
    final perms = user.permissions;

    return MethodistCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: context.responsivePadding(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: MethodistTheme.primaryRed.withValues(alpha: 0.1),
            child: Text(
              _getInitials(name),
              style: context.responsiveBodyMedium.copyWith(
                color: MethodistTheme.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            name.isEmpty ? 'Unnamed User' : name,
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
                    color: MethodistTheme.mediumGray,
                  ),
                  SizedBox(width: context.spacing(4)),
                  Text(
                    user.phone.isEmpty ? 'No phone' : user.phone,
                    style: context.responsiveBodySmall.copyWith(
                      color: MethodistTheme.mediumGray,
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
                      color: MethodistTheme.mediumGray,
                    ),
                    SizedBox(width: context.spacing(4)),
                    Text(
                      user.district!,
                      style: context.responsiveBodySmall.copyWith(
                        color: MethodistTheme.mediumGray,
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
          children: [_buildUserDetails(user, camps, myfs)],
        ),
      ),
    );
  }

  Widget _buildUserDetails(
    AppUser user,
    List<Map<String, Object>> camps,
    List<Map<String, Object>> myfs,
  ) {
    return Container(
      width: double.infinity,
      padding: context.responsivePadding(all: 16),
      decoration: BoxDecoration(
        color: MethodistTheme.lightGray,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.responsiveRadius(12)),
          bottomRight: Radius.circular(context.responsiveRadius(12)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.person, 'User Information'),
          SizedBox(height: context.spacing(8)),
          _buildInfoCard([
            if ((user.district ?? '').isNotEmpty)
              _buildInfoRow(
                Icons.location_city,
                'District',
                user.district ?? '',
              ),
            if ((user.church ?? '').isNotEmpty)
              _buildInfoRow(Icons.church, 'Church', user.church ?? ''),
            if ((user.gender ?? '').isNotEmpty)
              _buildInfoRow(Icons.wc, 'Gender', user.gender ?? ''),
          ]),

          SizedBox(height: context.spacing(20)),

          _buildSectionHeader(
            Icons.security,
            'Permissions Manager',
            subtitle: '${user.permissions.length} active permissions',
          ),
          SizedBox(height: context.spacing(12)),

          if (camps.isEmpty)
            _buildNoItemsAvailable(
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
              onPermissionChanged: (id, enabled) => _setCampPermission(
                uid: user.uid,
                campId: id,
                enabled: enabled,
              ),
            ),

          SizedBox(height: context.spacing(16)),

          if (myfs.isEmpty)
            _buildNoItemsAvailable(
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
              onPermissionChanged: (id, enabled) =>
                  _setMyfPermission(uid: user.uid, myfId: id, enabled: enabled),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, {String? subtitle}) {
    return Row(
      children: [
        Container(
          padding: context.responsivePadding(all: 8),
          decoration: BoxDecoration(
            color: MethodistTheme.primaryRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
          ),
          child: Icon(
            icon,
            color: MethodistTheme.primaryRed,
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
                  color: MethodistTheme.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: context.responsiveBodySmall.copyWith(
                    color: MethodistTheme.mediumGray,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: context.responsivePadding(all: 12),
      decoration: BoxDecoration(
        color: MethodistTheme.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        border: Border.all(
          color: MethodistTheme.mediumGray.withValues(alpha: 0.2),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
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
            color: MethodistTheme.primaryRed.withValues(alpha: 0.7),
          ),
          SizedBox(width: context.spacing(12)),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: context.responsiveBodySmall.copyWith(
                color: MethodistTheme.mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.responsiveBodySmall.copyWith(
                color: MethodistTheme.darkGray,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoItemsAvailable(
    String itemType,
    String message,
    IconData icon,
  ) {
    return Container(
      padding: context.responsivePadding(all: 16),
      decoration: BoxDecoration(
        color: MethodistTheme.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        border: Border.all(
          color: MethodistTheme.mediumGray.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: context.responsivePadding(all: 12),
            decoration: BoxDecoration(
              color: MethodistTheme.mediumGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.responsiveRadius(10)),
            ),
            child: Icon(
              icon,
              color: MethodistTheme.mediumGray,
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

  Widget _buildPermissionsSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Map<String, Object>> items,
    required List<String> userPermissions,
    required Function(String id, bool enabled) onPermissionChanged,
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
                  color: MethodistTheme.primaryRed,
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
            color: MethodistTheme.white,
            borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
            border: Border.all(
              color: MethodistTheme.mediumGray.withValues(alpha: 0.2),
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
                onChanged: (isSelected) =>
                    onPermissionChanged(itemId, isSelected),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: 'No Users Found',
      description: _search.isNotEmpty
          ? 'No users match "$_search". Try a different search term.'
          : 'No users match your current filters. Try adjusting your criteria.',
    );
  }

  Widget _buildErrorState(String title, String description) {
    return ErrorStateWidget(
      title: title,
      description: description,
      onRetry: () => setState(() {}),
    );
  }

  List<Map<String, Object>> _processCollection(
    List<QueryDocumentSnapshot> docs,
  ) {
    return docs.map((d) {
      final data = d.data() as Map<String, dynamic>? ?? {};
      final title = (data['title'] as String?)?.trim();
      return {
        'id': d.id,
        'title': (title == null || title.isEmpty) ? d.id : title,
      };
    }).toList()..sort(
      (a, b) => (a['title'] as String).toLowerCase().compareTo(
        (b['title'] as String).toLowerCase(),
      ),
    );
  }

  (List<String>, List<String>) _extractFilters(List<AppUser> users) {
    final districts = <String>{};
    final genders = <String>{};

    for (final u in users) {
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

    return (districtList, genderList);
  }

  List<AppUser> _applyFilters(List<AppUser> allUsers) {
    List<AppUser> filtered = allUsers.where((u) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final name = _fullName(u).toLowerCase();
        final matches =
            name.contains(q) ||
            (u.firstName ?? '').toLowerCase().contains(q) ||
            (u.lastName ?? '').toLowerCase().contains(q) ||
            u.phone.toLowerCase().contains(q) ||
            (u.district ?? '').toLowerCase().contains(q) ||
            (u.church ?? '').toLowerCase().contains(q) ||
            u.uid.toLowerCase().contains(q);
        if (!matches) return false;
      }

      if (_selectedGender != null && u.gender != _selectedGender) {
        return false;
      }

      if (_selectedDistrict != null && u.district != _selectedDistrict) {
        return false;
      }

      final selectedId = _permissionType == PermissionType.camps
          ? _selectedCampId
          : _selectedMyfId;

      if (selectedId != null && _permFilter != PermissionFilter.all) {
        final has = u.permissions.contains(selectedId);
        if (_permFilter == PermissionFilter.has && !has) return false;
        if (_permFilter == PermissionFilter.not && has) return false;
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      int r = 0;
      switch (_sortBy) {
        case SortBy.name:
          r = _fullName(a).toLowerCase().compareTo(_fullName(b).toLowerCase());
          break;
        case SortBy.phone:
          r = a.phone.toLowerCase().compareTo(b.phone.toLowerCase());
          break;
        case SortBy.district:
          r = (a.district ?? '').toLowerCase().compareTo(
            (b.district ?? '').toLowerCase(),
          );
          break;
        case SortBy.permissions:
          r = a.permissions.length.compareTo(b.permissions.length);
          break;
      }
      return _sortOrder == SortOrder.asc ? r : -r;
    });

    return filtered;
  }

  String _fullName(AppUser u) =>
      '${u.firstName ?? ''} ${u.lastName ?? ''}'.trim();

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
