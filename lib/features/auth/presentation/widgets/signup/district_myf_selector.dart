import 'package:flutter/material.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/features/auth/data/models/district_data.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


/// A compound widget that renders the District dropdown and the conditional
/// Church/MYF dropdown (or text field when "Other" is selected).
///
/// This is a self-contained form section, designed to be embedded inside a
/// [Form] widget for validation support.
class DistrictMyfSelector extends StatelessWidget {
  final String? selectedDistrict;
  final String? selectedMyf;
  final TextEditingController otherMyfController;
  final ValueChanged<String?> onDistrictChanged;
  final ValueChanged<String?> onMyfChanged;
  final FormFieldValidator<String?>? districtValidator;
  final FormFieldValidator<String?>? myfValidator;

  const DistrictMyfSelector({
    super.key,
    required this.selectedDistrict,
    required this.selectedMyf,
    required this.otherMyfController,
    required this.onDistrictChanged,
    required this.onMyfChanged,
    this.districtValidator,
    this.myfValidator,
  });

  bool get _isOtherDistrict => selectedDistrict == 'Other';

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: context.typography.bodyMedium!,
      hintText: hint,
      hintStyle: context.typography.bodyMedium!,
      border: OutlineInputBorder(
        borderRadius: context.radiusMd,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: context.colors.primary, width: 2),
        borderRadius: context.radiusMd,
      ),
      contentPadding: context.responsivePadding(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- District Dropdown ---
        DropdownButtonFormField<String>(
          initialValue: selectedDistrict,
          isExpanded: true,
          menuMaxHeight: 300,
          decoration: _inputDecoration(
            context,
            label: 'District',
            hint: 'Select your district',
          ),
          items: DistrictData.districts.map((district) {
            return DropdownMenuItem(
              value: district,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 80,
                child: Text(
                  district,
                  style: context.typography.bodyMedium!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
          onChanged: onDistrictChanged,
          validator: districtValidator,
        ),

        SizedBox(height: context.spacingMd),

        // --- Church/MYF Selector (conditional) ---
        if (selectedDistrict != null && !_isOtherDistrict)
          DropdownButtonFormField<String>(
            initialValue: selectedMyf,
            isExpanded: true,
            menuMaxHeight: 300,
            decoration: _inputDecoration(
              context,
              label: 'Church/MYF',
              hint: 'Select your church/MYF',
            ),
            items: DistrictData.getMyfsByDistrict(selectedDistrict!).map((myf) {
              return DropdownMenuItem(
                value: myf,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 80,
                  child: Text(
                    myf,
                    style: context.typography.bodyMedium!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
            onChanged: onMyfChanged,
            validator: myfValidator,
          )
        else if (selectedDistrict != null && _isOtherDistrict)
          AppTextField(
            controller: otherMyfController,
            onChanged: onMyfChanged,
            label: 'Church/MYF',
            hint: 'Enter your church/MYF name',
            textCapitalization: TextCapitalization.words,
            validator: myfValidator,
          ),
      ],
    );
  }
}
