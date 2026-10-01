import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';

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
        MyfTheme.showSuccessSnackBar(context, 'MYF created successfully');
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        MyfTheme.showErrorSnackBar(context, 'Error creating MYF: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyfTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Create New MYF',
          style: context.responsiveHeadlineSmall.copyWith(
            color: MyfTheme.white,
          ),
        ),
        backgroundColor: MyfTheme.primaryRed,
        foregroundColor: MyfTheme.white,
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        loadingMessage: 'Creating MYF...',
        child: SingleChildScrollView(
          padding: context.responsivePadding(all: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                MyfCard(
                  padding: context.responsivePadding(all: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: context.responsivePadding(all: 16),
                        decoration: BoxDecoration(
                          color: MyfTheme.primaryRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            context.responsiveRadius(20),
                          ),
                        ),
                        child: Icon(
                          Icons.group_add,
                          size: context.responsiveIconSize(48),
                          color: MyfTheme.primaryRed,
                        ),
                      ),
                      SizedBox(height: context.spacing(16)),
                      Text(
                        'Create New MYF Group',
                        style: context.responsiveHeadlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.spacing(8)),
                      Text(
                        'Fill in the details to create a new MYF group',
                        style: context.responsiveBodyMedium.copyWith(
                          color: MyfTheme.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing(24)),

                AppTextField(
                  controller: _titleController,
                  label: 'MYF Title',
                  hint: 'Enter MYF group title',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Title is required'
                      : null,
                ),

                SizedBox(height: context.spacing(16)),

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

                SizedBox(height: context.spacing(32)),

                Column(
                  children: [
                    PrimaryButton(
                      label: 'Create MYF',
                      onPressed: _saveMyf,
                      loading: _loading,
                      fullWidth: true,
                      icon: Icons.add_circle,
                    ),
                    SizedBox(height: context.spacing(12)),
                    PrimaryButton.secondary(
                      label: 'Cancel',
                      onPressed: _loading ? null : () => context.pop(),
                      fullWidth: true,
                      icon: Icons.cancel,
                    ),
                  ],
                ),

                SizedBox(height: context.spacing(24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
