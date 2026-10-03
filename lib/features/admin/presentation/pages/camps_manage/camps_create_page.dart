import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show Timestamp, FieldValue;
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_snackbars.dart';


class CampsCreatePage extends StatefulWidget {
  const CampsCreatePage({super.key});

  @override
  State<CampsCreatePage> createState() => _CampsCreatePageState();
}

class _CampsCreatePageState extends State<CampsCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCamp() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      AppSnackbars.showError(context, 'Please select a date');
      return;
    }

    setState(() => _loading = true);
    final navigator = Navigator.of(context);

    try {
      await di.sl<AdminRepository>().createCamp({
        'title': _titleController.text.trim(),
        'place': _placeController.text.trim(),
        'date': Timestamp.fromDate(_selectedDate!),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        AppSnackbars.showSuccess(context, 'Camp created successfully');
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, 'Error creating camp: $e');
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
          'Create New Camp',
          style: context.typography.headlineSmall!.copyWith(
            color: context.colors.surface,
          ),
        ),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.surface,
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        loadingMessage: 'Creating camp...',
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
                            Icons.add_business,
                            size: context.responsiveIconSize(48),
                            color: context.colors.primary,
                          ),
                        ),
                        SizedBox(height: context.spacingMd),
                        Text(
                          'Create New Camp',
                          style: context.typography.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.spacingSm),
                        Text(
                          'Fill in the details to create a new MYF camp',
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
                    label: 'Camp Title',
                    hint: 'Enter camp title',
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Title is required'
                        : null,
                  ),

                  SizedBox(height: context.spacingMd),

                  AppTextField(
                    controller: _placeController,
                    label: 'Place',
                    hint: 'Enter camp location',
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Place is required'
                        : null,
                  ),

                  SizedBox(height: context.spacingMd),

                  DatePickerField.dateOnly(
                    selectedDateTime: _selectedDate,
                    label: 'Camp Date',
                    hint: 'Select camp date',
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime(DateTime.now().year + 2),
                    onDateTimeSelected: (date) =>
                        setState(() => _selectedDate = date),
                  ),

                  SizedBox(height: context.spacingMd),

                  AppTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Enter camp description',
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Description is required'
                        : null,
                  ),

                  SizedBox(height: context.spacingXl),

                  Column(
                    children: [
                      PrimaryButton(
                        label: 'Create Camp',
                        onPressed: _saveCamp,
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
