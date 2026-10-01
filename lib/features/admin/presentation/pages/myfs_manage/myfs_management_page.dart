import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myf_connect/core/config/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_myfs_cubit.dart';
import 'package:myf_connect/features/admin/presentation/pages/myfs_manage/myfs_events_management_page.dart';

class MyfsManagementPage extends StatelessWidget {
  const MyfsManagementPage({super.key});

  Future<void> _navigateToCreateMyf(BuildContext context) async {
    await context.push(AppRoutes.adminMyfsCreate);
  }

  Future<void> _deleteMyf(BuildContext context, String id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete MYF', style: context.responsiveHeadlineSmall),
        content: Text(
          'Are you sure you want to delete "$title" and all its events? This cannot be undone.',
          style: context.responsiveBodyMedium,
        ),
        actionsPadding: context.responsivePadding(horizontal: 16, vertical: 12),
        actions: [
          PrimaryButton.secondary(
            label: 'Cancel',
            onPressed: () => dialogContext.pop(false),
          ),
          SizedBox(width: context.spacing(8)),
          PrimaryButton.danger(
            label: 'Delete',
            onPressed: () => dialogContext.pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => PopScope(
        canPop: false,
        child: const LoadingWidget(message: 'Deleting MYF and events...'),
      ),
    );

    try {
      await di.sl<AdminRepository>().deleteMyf(id);

      navigator.pop();

      if (context.mounted) {
        MyfTheme.showSuccessSnackBar(
          context,
          'MYF and all events deleted successfully',
        );
      }
    } catch (e) {
      debugPrint('❌ MYF Delete Error: $e');

      navigator.pop();

      if (context.mounted) {
        MyfTheme.showErrorSnackBar(
          context,
          'Failed to delete MYF: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _showEditMyfDialog(
    BuildContext context,
    String myfId,
    Map<String, dynamic> data,
  ) async {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: data['title'] ?? '');
    final descCtrl = TextEditingController(text: data['description'] ?? '');
    bool loading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit MYF', style: context.responsiveHeadlineSmall),
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
                      label: 'MYF Title',
                      hint: 'Enter MYF group title',
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Title is required'
                          : null,
                    ),
                    SizedBox(height: context.spacing(16)),

                    AppTextField(
                      controller: descCtrl,
                      label: 'Description',
                      hint: 'Enter MYF group description',
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
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
            SizedBox(width: context.spacing(8)),
            PrimaryButton(
              label: 'Update MYF',
              loading: loading,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                setDialogState(() => loading = true);

                try {
                  await di.sl<AdminRepository>().updateMyf(myfId, {
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (dialogContext.mounted) {
                    dialogContext.pop();
                    MyfTheme.showSuccessSnackBar(
                      context,
                      'MYF updated successfully',
                    );
                  }
                } catch (e) {
                  debugPrint('❌ MYF Update Error: $e');
                  MyfTheme.showErrorSnackBar(context, 'Error updating MYF: $e');
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
    return Scaffold(
      backgroundColor: MyfTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'MYF Management',
          style: context.responsiveHeadlineSmall.copyWith(
            color: MyfTheme.white,
          ),
        ),
        backgroundColor: MyfTheme.primaryRed,
        foregroundColor: MyfTheme.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateMyf(context),
        tooltip: 'Add MYF',
        backgroundColor: MyfTheme.primaryRed,
        foregroundColor: MyfTheme.white,
        child: Icon(Icons.add, size: context.responsiveIconSize(28)),
      ),
      body: BlocProvider(
        create: (context) => di.sl<AdminMyfsCubit>(),
        child: BlocBuilder<AdminMyfsCubit, AdminMyfsState>(
          builder: (context, state) {
            if (state is AdminMyfsLoading || state is AdminMyfsInitial) {
              return const LoadingWidget(message: 'Loading MYF groups...');
            }

            if (state is AdminMyfsError) {
              return ErrorStateWidget(
                title: 'Error Loading MYF Groups',
                description: 'Error: ${state.message}',
                onRetry: () {
                  context.read<AdminMyfsCubit>().loadMyfs();
                },
              );
            }

            if (state is AdminMyfsLoaded) {
              final myfDocs = state.snapshot.docs;

              if (myfDocs.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.group,
                  title: 'No MYF Groups Found',
                  description:
                      'No MYF groups have been created yet. Tap the + button to create your first MYF group.',
                );
              }

              return ListView.builder(
                padding: context.responsivePadding(all: 16),
                itemCount: myfDocs.length,
                itemBuilder: (context, index) {
                  final myf = myfDocs[index];
                  final data = myf.data() as Map<String, dynamic>;
                  final myfId = myf.id;
                  final title = data['title'] ?? 'Untitled MYF';
                  final description = data['description'] ?? '';

                  return Column(
                    children: [
                      InfoCard(
                        title: title,
                        description: description.isNotEmpty
                            ? description
                            : 'No description available',
                        icon: Icons.group,
                        actions: [
                          Tooltip(
                            message: 'Edit MYF',
                            child: IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: MyfTheme.warningOrange,
                                size: context.responsiveIconSize(20),
                              ),
                              onPressed: () =>
                                  _showEditMyfDialog(context, myfId, data),
                            ),
                          ),
                          Tooltip(
                            message: 'Manage Events',
                            child: IconButton(
                              icon: Icon(
                                Icons.event,
                                color: MyfTheme.infoBlue,
                                size: context.responsiveIconSize(20),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MyfsEventsManagementPage(
                                      myfId: myfId,
                                      myfTitle: title,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Tooltip(
                            message: 'Delete MYF',
                            child: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: MyfTheme.errorRed,
                                size: context.responsiveIconSize(20),
                              ),
                              onPressed: () =>
                                  _deleteMyf(context, myfId, title),
                            ),
                          ),
                        ],
                      ),
                      if (index < myfDocs.length - 1)
                        SizedBox(height: context.spacing(12)),
                    ],
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
