import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/widgets.dart';

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
      await FirebaseFirestore.instance.collection('myfs').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        MethodistTheme.showSuccessSnackBar(
            context, 'MYF created successfully');
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        MethodistTheme.showErrorSnackBar(context, 'Error creating MYF: $e');
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
          'Create New MYF',
          style: context.responsiveHeadlineSmall.copyWith(
            color: MethodistTheme.white,
          ),
        ),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        loadingMessage: 'Creating MYF...',
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
                          Icons.group_add,
                          size: context.responsiveIconSize(48),
                          color: MethodistTheme.primaryRed,
                        ),
                      ),
                      // ✅ RESPONSIVE: Use context.spacing
                      SizedBox(height: context.spacing(16)),
                      Text(
                        'Create New MYF Group',
                        // ✅ RESPONSIVE: Use responsive text style
                        style: context.responsiveHeadlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.spacing(8)),
                      Text(
                        'Fill in the details to create a new Methodist Youth Fellowship group',
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

                // ========== MYF Title Field ==========
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

                // ========== MYF Description Field ==========
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

                // ========== Action Buttons ==========
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
