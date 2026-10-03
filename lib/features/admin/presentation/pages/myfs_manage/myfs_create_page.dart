import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_snackbars.dart';


class MyfsCreatePage extends StatefulWidget {
  const MyfsCreatePage({super.key});

  @override
  State<MyfsCreatePage> createState() => _MyfsCreatePageState();
}

class _MyfsCreatePageState extends State<MyfsCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveMyf() async {
    if (_loading) return;
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _loading = true);
    final navigator = Navigator.of(context);

    try {
      await di.sl<AdminRepository>().createMyf({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        AppSnackbars.showSuccess(context, 'MYF created successfully');
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, 'Error creating MYF: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: context.colors.background,
      appBar: PlatformAppBar(
        title: Text(
          'Create New MYF',
          style: context.typography.headlineSmall!.copyWith(
            color: context.colors.surface,
          ),
        ),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.surface,
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        loadingMessage: 'Creating MYF...',
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacingLg),
          child: ResponsiveConstrainedBox(
            maxWidth: 600,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  MyfCard(
                    padding: EdgeInsets.all(context.spacingLg),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(context.spacingMd),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              context.radiusXl.topLeft.x,
                            ),
                          ),
                          child: Icon(
                            Icons.group_add,
                            size: context.responsiveIconSize(48),
                            color: context.colors.primary,
                          ),
                        ),
                        SizedBox(height: context.spacingMd),
                        Text(
                          'Create New MYF Group',
                          style: context.typography.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.spacingSm),
                        Text(
                          'Fill in the details to create a new MYF group',
                          style: context.typography.bodyMedium!.copyWith(
                            color: context.colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.spacingLg),

                  AppTextField(
                    controller: _titleController,
                    label: 'MYF Title',
                    hint: 'Enter MYF group title',
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Title is required'
                        : null,
                  ),

                  SizedBox(height: context.spacingMd),

                  AppTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Enter MYF group description',
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 4,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Description is required'
                        : null,
                  ),

                  SizedBox(height: context.spacingXl),

                  Column(
                    children: [
                      PrimaryButton(
                        label: 'Create MYF',
                        onPressed: _saveMyf,
                        loading: _loading,
                        fullWidth: true,
                        icon: Icons.add_circle,
                      ),
                      SizedBox(height: context.spacingMd),
                      PrimaryButton.secondary(
                        label: 'Cancel',
                        onPressed: _loading ? null : () => context.pop(),
                        fullWidth: true,
                        icon: Icons.cancel,
                      ),
                    ],
                  ),

                  SizedBox(height: context.spacingLg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
