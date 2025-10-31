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
        // ✅ RESPONSIVE: Use responsive text style
        title: Text(
          'Create New Camp',
          style: context.responsiveHeadlineSmall.copyWith(
            color: MethodistTheme.white,
          ),
        ),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        loadingMessage: 'Creating camp...',
        child: SingleChildScrollView(
          // ✅ RESPONSIVE: Use context.responsivePadding
          padding: context.responsivePadding(all: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ========== Header Card ==========
                MethodistCard(
                  padding: context.responsivePadding(all: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: context.responsivePadding(all: 16),
                        decoration: BoxDecoration(
                          color: MethodistTheme.primaryRed.withValues(alpha: 0.1),
                          // ✅ RESPONSIVE: Use context.responsiveRadius
                          borderRadius: BorderRadius.circular(
                            context.responsiveRadius(20),
                          ),
                        ),
                        // ✅ RESPONSIVE: Use context.responsiveIconSize
                        child: Icon(
                          Icons.add_business,
                          size: context.responsiveIconSize(48),
                          color: MethodistTheme.primaryRed,
                        ),
                      ),
                      // ✅ RESPONSIVE: Use context.spacing
                      SizedBox(height: context.spacing(16)),
                      Text(
                        'Create New Camp',
                        // ✅ RESPONSIVE: Use responsive text style
                        style: context.responsiveHeadlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.spacing(8)),
                      Text(
                        'Fill in the details to create a new Methodist camp',
                        // ✅ RESPONSIVE: Use responsive text style
                        style: context.responsiveBodyMedium.copyWith(
                          color: MethodistTheme.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing(24)),

                // ========== Camp Title Field ==========
                AppTextField(
                  controller: _titleController,
                  label: 'Camp Title',
                  hint: 'Enter camp title',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
                ),

                SizedBox(height: context.spacing(16)),

                // ========== Place Field ==========
                AppTextField(
                  controller: _placeController,
                  label: 'Place',
                  hint: 'Enter camp location',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Place is required' : null,
                ),

                SizedBox(height: context.spacing(16)),

                // ========== Camp Date Field ==========
                DatePickerField.dateOnly(
                  selectedDateTime: _selectedDate,
                  label: 'Camp Date',
                  hint: 'Select camp date',
                  firstDate: DateTime(DateTime.now().year - 1),
                  lastDate: DateTime(DateTime.now().year + 2),
                  onDateTimeSelected: (date) =>
                      setState(() => _selectedDate = date),
                ),

                SizedBox(height: context.spacing(16)),

                // ========== Description Field ==========
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

                SizedBox(height: context.spacing(32)),

                // ========== Action Buttons ==========
                Column(
                  children: [
                    PrimaryButton(
                      label: 'Create Camp',
                      onPressed: _saveCamp,
                      loading: _loading,
                      fullWidth: true,
                      icon: Icons.add_circle,
                    ),
                    SizedBox(height: context.spacing(12)),
                    PrimaryButton.secondary(
                      label: 'Cancel',
                      onPressed: _loading ? null : () => Navigator.pop(context),
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
