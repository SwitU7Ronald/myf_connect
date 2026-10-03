import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show QueryDocumentSnapshot;
import 'package:myf_connect/core/models/app_user.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_camps_cubit.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_myfs_cubit.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_users_cubit.dart';
import 'package:myf_connect/features/admin/presentation/widgets/user_filter_bar.dart';
import 'package:myf_connect/features/admin/presentation/widgets/users_manage/user_filter_enums.dart';
import 'package:myf_connect/features/admin/presentation/widgets/user_stats_card.dart';
import 'package:myf_connect/features/admin/presentation/widgets/users_manage/user_card_item.dart';
import 'dart:async';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_snackbars.dart';


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
      if (enabled) {
        await di.sl<AdminRepository>().grantPermission(uid, campId);
      } else {
        await di.sl<AdminRepository>().revokePermission(uid, campId);
      }

      if (mounted) {
        AppSnackbars.showSuccess(
          context,
          enabled ? 'Camp permission granted' : 'Camp permission removed',
        );
      }
    } catch (e) {
      debugPrint('Error updating camp permission: $e');
      if (mounted) {
        AppSnackbars.showError(context, 'Failed to update camp permission');
      }
    }
  }

  Future<void> _setMyfPermission({
    required String uid,
    required String myfId,
    required bool enabled,
  }) async {
    try {
      if (enabled) {
        await di.sl<AdminRepository>().grantPermission(uid, myfId);
      } else {
        await di.sl<AdminRepository>().revokePermission(uid, myfId);
      }

      if (mounted) {
        AppSnackbars.showSuccess(
          context,
          enabled ? 'MYF permission granted' : 'MYF permission removed',
        );
      }
    } catch (e) {
      debugPrint('Error updating MYF permission: $e');
      if (mounted) {
        AppSnackbars.showError(context, 'Failed to update MYF permission');
      }
    }
  }

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
      child: PlatformScaffold(
        backgroundColor: context.colors.background,
        appBar: _buildPlatformAppBar(),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.sl<AdminCampsCubit>()),
            BlocProvider(create: (_) => di.sl<AdminMyfsCubit>()),
            BlocProvider(create: (_) => di.sl<AdminUsersCubit>()),
          ],
          child: BlocBuilder<AdminCampsCubit, AdminCampsState>(
            builder: (context, campsState) {
              if (campsState is AdminCampsError) {
                return _buildErrorState(
                  'Error Loading Camps',
                  'Failed to load camps data. Check your connection.',
                );
              }

              if (campsState is AdminCampsLoaded) {
                _campsCache = _processCollection(campsState.snapshot.docs);
              }

              return BlocBuilder<AdminMyfsCubit, AdminMyfsState>(
                builder: (context, myfsState) {
                  if (myfsState is AdminMyfsError) {
                    return _buildErrorState(
                      'Error Loading MYF Groups',
                      'Failed to load MYF groups data. Check your connection.',
                    );
                  }

                  if (myfsState is AdminMyfsLoaded) {
                    _myfsCache = _processCollection(myfsState.snapshot.docs);
                  }

                  return BlocBuilder<AdminUsersCubit, AdminUsersState>(
                    builder: (context, usersState) {
                      if ((usersState is AdminUsersLoading ||
                              usersState is AdminUsersInitial) &&
                          _usersCache.isEmpty) {
                        return const LoadingWidget(message: 'Loading users...');
                      }

                      if (usersState is AdminUsersError) {
                        return _buildErrorState(
                          'Error Loading Users',
                          'Failed to load users data. Please try again.',
                        );
                      }

                      if (usersState is AdminUsersLoaded) {
                        _usersCache = usersState.snapshot.docs
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

                      return Padding(
                        padding: EdgeInsets.only(top: context.appBarOverlap),
                        child: Column(
                          children: [
                          UserStatsCard(
                            total: _usersCache.length,
                            filtered: filtered.length,
                            hasFilters:
                                _search.isNotEmpty ||
                                _selectedGender != null ||
                                _selectedDistrict != null ||
                                _selectedCampId != null ||
                                _selectedMyfId != null ||
                                _permFilter != PermissionFilter.all,
                          ),

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
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildPlatformAppBar() {
    return PlatformAppBar(
      title: Text(
        'Users Management',
        style: context.typography.headlineSmall!.copyWith(
          color: context.colors.surface,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: context.colors.primary,
      foregroundColor: context.colors.surface,
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

  Widget _buildUserList(
    List<AppUser> users,
    List<Map<String, Object>> camps,
    List<Map<String, Object>> myfs,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        Widget buildItem(BuildContext context, int index) {
          final user = users[index];
          return UserCardItem(
            user: user,
            camps: camps,
            myfs: myfs,
            onCampPermissionChanged: (id, enabled) =>
                _setCampPermission(uid: user.uid, campId: id, enabled: enabled),
            onMyfPermissionChanged: (id, enabled) =>
                _setMyfPermission(uid: user.uid, myfId: id, enabled: enabled),
          );
        }

        if (isWide) {
          return GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(context.spacingMd),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              crossAxisSpacing: context.spacingMd,
              mainAxisSpacing: context.spacingMd,
              mainAxisExtent: 220,
            ),
            itemCount: users.length,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemBuilder: buildItem,
          );
        }

        return ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.all(context.spacingMd),
          itemCount: users.length,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          separatorBuilder: (context, index) =>
              SizedBox(height: context.spacingMd),
          itemBuilder: buildItem,
        );
      },
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
    List<QueryDocumentSnapshot<Object?>> docs,
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
}
