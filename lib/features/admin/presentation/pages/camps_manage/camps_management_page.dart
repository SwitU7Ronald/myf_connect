import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myf_connect/core/routes/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show Timestamp, FieldValue;
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_camps_cubit.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_snackbars.dart';


class CampsManagementPage extends StatelessWidget {
  const CampsManagementPage({super.key});

  Future<void> _navigateToCreateCamp(BuildContext context) async {
    await context.push(AppRoutes.adminCampsCreate);
  }

  Future<void> _deleteCamp(
    BuildContext context,
    String id,
    String title,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => PlatformAlertDialog(
        title: Text('Delete Camp', style: context.typography.headlineSmall),
        content: Text(
          'Are you sure you want to delete "$title" and all its events? This cannot be undone.',
          style: context.typography.bodyMedium,
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: context.spacingMd, vertical: context.spacingMd),
        actions: [
          PrimaryButton.secondary(
            label: 'Cancel',
            onPressed: () => dialogContext.pop(false),
          ),
          SizedBox(width: context.spacingSm),
          PrimaryButton.danger(
            label: 'Delete',
            onPressed: () => dialogContext.pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final navigator = Navigator.of(context);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => PopScope(
        canPop: false,
        child: const LoadingWidget(message: 'Deleting camp and events...'),
      ),
    );

    try {
      await di.sl<AdminRepository>().deleteCamp(id);

      navigator.pop();

      if (context.mounted) {
        AppSnackbars.showSuccess(
          context,
          'Camp and all events deleted successfully',
        );
      }
    } catch (e) {
      debugPrint('❌ Camp Delete Error: $e');

      navigator.pop();

      if (context.mounted) {
        AppSnackbars.showError(
          context,
          'Failed to delete camp: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _showEditCampDialog(
    BuildContext context,
    String campId,
    Map<String, dynamic> data,
  ) async {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(
      text: data['title'] as String? ?? '',
    );
    final placeCtrl = TextEditingController(
      text: data['place'] as String? ?? '',
    );
    final descCtrl = TextEditingController(
      text: data['description'] as String? ?? '',
    );

    DateTime? selectedDate = () {
      final raw = data['date'];
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw);
      return null;
    }();

    bool loading = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => PlatformAlertDialog(
          title: Text('Edit Camp', style: context.typography.headlineSmall),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      controller: titleCtrl,
                      label: 'Camp Title',
                      hint: 'Enter camp title',
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Title is required'
                          : null,
                    ),
                    SizedBox(height: context.spacingMd),

                    AppTextField(
                      controller: placeCtrl,
                      label: 'Place',
                      hint: 'Enter camp location',
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Place is required'
                          : null,
                    ),
                    SizedBox(height: context.spacingMd),

                    DatePickerField.dateOnly(
                      selectedDateTime: selectedDate,
                      label: 'Camp Date',
                      hint: 'Select camp date',
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                      onDateTimeSelected: (date) =>
                          setDialogState(() => selectedDate = date),
                    ),
                    SizedBox(height: context.spacingMd),

                    AppTextField(
                      controller: descCtrl,
                      label: 'Description',
                      hint: 'Enter camp description',
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Description is required'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: context.responsivePadding(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            PrimaryButton.secondary(
              label: 'Cancel',
              onPressed: () => dialogContext.pop(),
            ),
            SizedBox(width: context.spacingSm),
            PrimaryButton(
              label: 'Update Camp',
              loading: loading,
              onPressed: () async {
                if (!formKey.currentState!.validate() || selectedDate == null) {
                  if (selectedDate == null) {
                    AppSnackbars.showError(context, 'Please select a date');
                  }
                  return;
                }

                setDialogState(() => loading = true);

                try {
                  final dayOfWeek = [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday',
                  ];
                  final day = dayOfWeek[selectedDate!.weekday - 1];

                  await di.sl<AdminRepository>().updateCamp(campId, {
                    'title': titleCtrl.text.trim(),
                    'place': placeCtrl.text.trim(),
                    'date': Timestamp.fromDate(selectedDate!),
                    'day': day,
                    'description': descCtrl.text.trim(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (dialogContext.mounted) {
                    dialogContext.pop();
                    AppSnackbars.showSuccess(
                      context,
                      'Camp updated successfully',
                    );
                  }
                } catch (e) {
                  debugPrint('Camp Update Error: $e');
                  AppSnackbars.showError(
                    context,
                    'Error updating camp: $e',
                  );
                } finally {
                  setDialogState(() => loading = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: context.colors.background,
      appBar: PlatformAppBar(
        title: Text(
          'Camps Management',
          style: context.typography.headlineSmall!.copyWith(
            color: context.colors.surface,
          ),
        ),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.surface,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateCamp(context),
        tooltip: 'Add Camp',
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.surface,
        child: Icon(Icons.add, size: context.responsiveIconSize(28)),
      ),
      body: BlocProvider(
        create: (context) => di.sl<AdminCampsCubit>(),
        child: BlocBuilder<AdminCampsCubit, AdminCampsState>(
          builder: (context, state) {
            if (state is AdminCampsLoading || state is AdminCampsInitial) {
              return const LoadingWidget(message: 'Loading camps...');
            }

            if (state is AdminCampsError) {
              return ErrorStateWidget(
                title: 'Error Loading Camps',
                description: 'Error: ${state.message}',
                onRetry: () {
                  context.read<AdminCampsCubit>().loadCamps();
                },
              );
            }

            if (state is AdminCampsLoaded) {
              final camps = state.snapshot.docs;

              if (camps.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.campaign,
                  title: 'No Camps Found',
                  description:
                      'No camps have been created yet. Tap the + button to create your first camp.',
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;

                  Widget buildItem(BuildContext context, int index) {
                    final camp = camps[index];
                    final campId = camp.id;
                    final data = camp.data() as Map<String, dynamic>;
                    final title = data['title'] as String? ?? 'Unnamed Camp';
                    final place = data['place'] as String? ?? '';

                    String dateStr = '';
                    final dateVal = data['date'];
                    if (dateVal is Timestamp) {
                      dateStr = dateVal
                          .toDate()
                          .toLocal()
                          .toString()
                          .split(' ')
                          .first;
                    } else if (dateVal is String) {
                      final parsedDate = DateTime.tryParse(dateVal);
                      dateStr =
                          parsedDate?.toLocal().toString().split(' ').first ??
                          '';
                    }

                    return InfoCard(
                      title: title,
                      subtitle: place.isNotEmpty ? place : null,
                      description: dateStr.isNotEmpty ? 'Date: $dateStr' : null,
                      icon: Icons.campaign,
                      actions: [
                        Tooltip(
                          message: 'Edit Camp',
                          child: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: context.colors.warning,
                              size: context.responsiveIconSize(20),
                            ),
                            onPressed: () =>
                                _showEditCampDialog(context, campId, data),
                          ),
                        ),
                        Tooltip(
                          message: 'Manage Events',
                          child: IconButton(
                            icon: Icon(
                              Icons.event,
                              color: context.colors.info,
                              size: context.responsiveIconSize(20),
                            ),
                            onPressed: () {
                              context.push('${AppRoutes.adminCamps}/$campId/events');
                            },
                          ),
                        ),
                        Tooltip(
                          message: 'Delete Camp',
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: context.colors.error,
                              size: context.responsiveIconSize(20),
                            ),
                            onPressed: () =>
                                _deleteCamp(context, campId, title),
                          ),
                        ),
                      ],
                    );
                  }

                  if (isWide) {
                    return GridView.builder(
                      padding: EdgeInsets.only(top: context.appBarOverlap + context.spacingMd, left: context.spacingMd, right: context.spacingMd, bottom: context.spacingMd),
                      gridDelegate:
                          SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            crossAxisSpacing: context.spacingMd,
                            mainAxisSpacing: context.spacingMd,
                            mainAxisExtent: 200,
                          ),
                      itemCount: camps.length,
                      itemBuilder: buildItem,
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(top: context.appBarOverlap + context.spacingMd, left: context.spacingMd, right: context.spacingMd, bottom: context.spacingMd),
                    itemCount: camps.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < camps.length - 1
                              ? context.spacingMd
                              : 0,
                        ),
                        child: buildItem(context, index),
                      );
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
