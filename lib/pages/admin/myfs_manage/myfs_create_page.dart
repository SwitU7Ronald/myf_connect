import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:methodist_connect/app/theme.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/loading_widgets.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/text_fields.dart';

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
        context.showSuccessSnackBar('MYF created successfully');
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error creating MYF: $e');
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
      appBar: AppBar(title: const Text('Create New MYF')),
      body: LoadingOverlay(
        isLoading: _loading,
        loadingMessage: 'Creating MYF...',
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
                          color: context.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(context.radiusXL),
                        ),
                        child: Icon(
                          Icons.group_add,
                          size: 48,
                          color: context.primaryColor,
                        ),
                      ),
                      SizedBox(height: context.spacingM),
                      Text(
                        'Create New MYF Group',
                        style: context.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.spacingS),
                      Text(
                        'Fill in the details to create a new Methodist Youth Fellowship group',
                        style: context.bodyMedium.copyWith(
                          color: context.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacingL),

                AppTextField(
                  controller: _titleController,
                  label: 'MYF Title',
                  hint: 'Enter MYF group title',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                ),

                SizedBox(height: context.spacingM),

                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Enter MYF group description',
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
                ),

                SizedBox(height: context.spacingXL),

                PrimaryButton(
                  label: 'Create MYF',
                  onPressed: _saveMyf,
                  loading: _loading,
                  fullWidth: true,
                  icon: Icons.add_circle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}