// lib/pages/admin/camps_manage/camps_create_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/widgets.dart';

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
      MethodistTheme.showErrorSnackBar(context, 'Please select a date');
      return;
    }

    setState(() => _loading = true);
    final navigator = Navigator.of(context);

    try {
      await FirebaseFirestore.instance.collection('camps').add({
        'title': _titleController.text.trim(),
        'place': _placeController.text.trim(),
        'date': Timestamp.fromDate(_selectedDate!),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        MethodistTheme.showSuccessSnackBar(context, 'Camp created successfully');
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        MethodistTheme.showErrorSnackBar(context, 'Error creating camp: $e');
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
      backgroundColor: MethodistTheme.lightGray,
      appBar: AppBar(
        title: const Text('Create New Camp'),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        loadingMessage: 'Creating camp...',
        child: SingleChildScrollView(
          padding: MethodistTheme.paddingL,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header card
                MethodistCard(
                  child: Column(
                    children: [
                      Container(
                        padding: MethodistTheme.paddingM,
                        decoration: BoxDecoration(
                          color: MethodistTheme.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(MethodistTheme.radiusXL),
                        ),
                        child: Icon(
                          Icons.add_business,
                          size: 48,
                          color: MethodistTheme.primaryRed,
                        ),
                      ),
                      SizedBox(height: MethodistTheme.spacingM),
                      Text(
                        'Create New Camp',
                        style: MethodistTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: MethodistTheme.spacingS),
                      Text(
                        'Fill in the details to create a new Methodist camp',
                        style: MethodistTheme.bodyMedium.copyWith(
                          color: MethodistTheme.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MethodistTheme.spacingL),

                AppTextField(
                  controller: _titleController,
                  label: 'Camp Title',
                  hint: 'Enter camp title',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                ),

                SizedBox(height: MethodistTheme.spacingM),

                AppTextField(
                  controller: _placeController,
                  label: 'Place',
                  hint: 'Enter camp location',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Place is required' : null,
                ),

                SizedBox(height: MethodistTheme.spacingM),

                DatePickerField(
                  selectedDate: _selectedDate,
                  label: 'Camp Date',
                  hint: 'Select camp date',
                  firstDate: DateTime(DateTime.now().year - 1),
                  lastDate: DateTime(DateTime.now().year + 2),
                  onDateSelected: (date) => setState(() => _selectedDate = date),
                ),

                SizedBox(height: MethodistTheme.spacingM),

                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Enter camp description',
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
                ),

                SizedBox(height: MethodistTheme.spacingXL),

                // Fixed: Action Buttons with better spacing and no overflow
                Column(
                  children: [
                    PrimaryButton(
                      label: 'Create Camp',
                      onPressed: _saveCamp,
                      loading: _loading,
                      fullWidth: true,
                      icon: Icons.add_circle,
                    ),
                    SizedBox(height: MethodistTheme.spacingM),
                    PrimaryButton.secondary(
                      label: 'Cancel',
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      fullWidth: true,
                      icon: Icons.cancel,
                    ),
                  ],
                ),

                SizedBox(height: MethodistTheme.spacingL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
