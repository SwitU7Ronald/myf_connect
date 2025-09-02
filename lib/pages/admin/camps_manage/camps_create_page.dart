import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:methodist_connect/app/theme.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/loading_widgets.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/text_fields.dart';

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

  Future<void> _saveCamp() async {
    if (_loading) return;
    if (_formKey.currentState?.validate() != true || _selectedDate == null) {
      context.showErrorSnackBar('Please fill all fields and select date');
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
      });

      if (mounted) {
        context.showSuccessSnackBar('Camp created successfully');
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error creating camp: $e');
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
      appBar: AppBar(title: const Text('Create New Camp')),
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
                          color: context.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(context.radiusXL),
                        ),
                        child: Icon(
                          Icons.campaign_outlined,
                          size: 48,
                          color: context.primaryColor,
                        ),
                      ),
                      SizedBox(height: context.spacingM),
                      Text(
                        'Create New Camp',
                        style: context.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.spacingS),
                      Text(
                        'Fill in the details to create a new Methodist camp',
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
                  label: 'Camp Title',
                  hint: 'Enter camp title',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                ),

                SizedBox(height: context.spacingM),

                AppTextField(
                  controller: _placeController,
                  label: 'Place',
                  hint: 'Enter camp location',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Place is required' : null,
                ),

                SizedBox(height: context.spacingM),

                DatePickerField(
                  selectedDate: _selectedDate,
                  label: 'Camp Date',
                  hint: 'Select camp date',
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  onDateSelected: (date) => setState(() => _selectedDate = date),
                ),

                SizedBox(height: context.spacingM),

                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Enter camp description',
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
                ),

                SizedBox(height: context.spacingXL),

                PrimaryButton(
                  label: 'Create Camp',
                  onPressed: _saveCamp,
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
    _placeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}