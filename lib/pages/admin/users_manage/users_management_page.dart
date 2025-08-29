import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/app_user.dart';

enum SortBy { name, phone, district, permissions }
enum SortOrder { asc, desc }
enum PermissionFilter { all, has, not }

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});
  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  // Search and sort
  String _search = '';
  SortBy _sortBy = SortBy.name;
  SortOrder _sortOrder = SortOrder.asc;

  // Attribute filters
  String? _selectedGender;   // null = all
  String? _selectedDistrict; // null = all

  // Camp permission filter
  String? _selectedCampId; // null = all camps
  PermissionFilter _permFilter = PermissionFilter.all;

  Future<void> _setCampPermission({
    required String uid,
    required String campId,
    required bool enabled,
  }) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    await ref.update({
      'permissions': enabled
          ? FieldValue.arrayUnion([campId])
          : FieldValue.arrayRemove([campId]),
    });
  }

  // Inclusive streams: no orderBy so docs without fields aren’t hidden
  Stream<QuerySnapshot> get _campsStream =>
      FirebaseFirestore.instance.collection('camps').snapshots();

  Stream<QuerySnapshot> get _usersStream =>
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users Management')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _campsStream,
        builder: (context, campsSnap) {
          if (campsSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (campsSnap.hasError) {
            return const Center(child: Text('Failed to load camps'));
          }

          final campDocs = campsSnap.data?.docs ?? const [];
          final camps = campDocs
              .map((d) {
            final data = d.data() as Map<String, dynamic>? ?? {};
            final title = (data['title'] as String?)?.trim();
            return {
              'id': d.id,
              'title': (title == null || title.isEmpty) ? d.id : title,
            };
          })
              .toList()
            ..sort((a, b) =>
                (a['title'] as String).toLowerCase().compareTo((b['title'] as String).toLowerCase()));

          return StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder: (context, usersSnap) {
              if (usersSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (usersSnap.hasError) {
                return const Center(child: Text('Failed to load users'));
              }

              final allUsers = usersSnap.data?.docs
                  .map((d) => AppUser.fromMap(
                d.id,
                d.data() as Map<String, dynamic>,
              ))
                  .toList() ??
                  [];

              // Build dynamic filter lists from current data
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

              String fullName(AppUser u) =>
                  ('${u.firstName ?? ''} ${u.lastName ?? ''}').trim();

              // Search and filters
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
                if (_selectedCampId == null ||
                    _permFilter == PermissionFilter.all) {
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
                    onDistrictChanged: (v) =>
                        setState(() => _selectedDistrict = v),
                    onClear: () {
                      setState(() {
                        _search = '';
                        _sortBy = SortBy.name;
                        _sortOrder = SortOrder.asc;
                        _selectedCampId = null;
                        _permFilter = PermissionFilter.all;
                        _selectedGender = null;
                        _selectedDistrict = null;
                      });
                    },
                  ),
                  if (filtered.isEmpty)
                    const Expanded(child: Center(child: Text('No users found')))
                  else
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          final name = fullName(user);
                          final perms = user.permissions;

                          return ExpansionTile(
                            title: Text(name.isEmpty ? 'Unnamed user' : name),
                            subtitle: Text(user.phone.isEmpty ? '-' : user.phone),
                            trailing: Text('${perms.length}'),
                            children: [
                              if (camps.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('No camps available'),
                                )
                              else
                                Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          'Camp permissions',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: camps.map((camp) {
                                          final campId =
                                          camp['id'] as String;
                                          final campTitle =
                                          camp['title'] as String;
                                          final selected =
                                          perms.contains(campId);
                                          return FilterChip(
                                            label: Text(campTitle),
                                            selected: selected,
                                            onSelected: (isSelected) {
                                              _setCampPermission(
                                                uid: user.uid,
                                                campId: campId,
                                                enabled: isSelected,
                                              );
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search name / phone / uid / district / church',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Sort by',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SortBy>(
                        isExpanded: true,
                        value: sortBy,
                        onChanged: (v) => v == null ? null : onSortByChanged(v),
                        items: const [
                          DropdownMenuItem(
                            value: SortBy.name,
                            child: Text('Name'),
                          ),
                          DropdownMenuItem(
                            value: SortBy.phone,
                            child: Text('Phone'),
                          ),
                          DropdownMenuItem(
                            value: SortBy.district,
                            child: Text('District'),
                          ),
                          DropdownMenuItem(
                            value: SortBy.permissions,
                            child: Text('Permissions count'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Order',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SortOrder>(
                        isExpanded: true,
                        value: sortOrder,
                        onChanged: (v) =>
                        v == null ? null : onSortOrderChanged(v),
                        items: const [
                          DropdownMenuItem(
                            value: SortOrder.asc,
                            child: Text('Ascending'),
                          ),
                          DropdownMenuItem(
                            value: SortOrder.desc,
                            child: Text('Descending'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Camp',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: selectedCampId,
                        onChanged: onCampChanged,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All camps'),
                          ),
                          ...camps.map((c) => DropdownMenuItem<String?>(
                            value: c['id'] as String,
                            child: Text(c['title'] as String),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Permission',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<PermissionFilter>(
                        isExpanded: true,
                        value: permFilter,
                        onChanged: (v) =>
                        v == null ? null : onPermFilterChanged(v),
                        items: const [
                          DropdownMenuItem(
                            value: PermissionFilter.all,
                            child: Text('All users'),
                          ),
                          DropdownMenuItem(
                            value: PermissionFilter.has,
                            child: Text('Has permission'),
                          ),
                          DropdownMenuItem(
                            value: PermissionFilter.not,
                            child: Text('No permission'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: selectedGender,
                        onChanged: onGenderChanged,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All'),
                          ),
                          ...genders.map((g) => DropdownMenuItem<String?>(
                            value: g,
                            child: Text(g),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'District',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: selectedDistrict,
                        onChanged: onDistrictChanged,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All'),
                          ),
                          ...districts.map((d) => DropdownMenuItem<String?>(
                            value: d,
                            child: Text(d),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
