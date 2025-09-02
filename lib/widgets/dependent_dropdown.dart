// lib/widgets/dependent_dropdown.dart
import 'package:flutter/material.dart';
import '../app/theme.dart';

class DependentDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String label;
  final String hint;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final Widget Function(T)? itemBuilder;

  const DependentDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.hint,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: itemBuilder?.call(item) ?? Text(
            item.toString(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        enabled: enabled,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MethodistTheme.spacingM,
          vertical: MethodistTheme.spacingM,
        ),
      ),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      style: MethodistTheme.bodyMedium,
      dropdownColor: MethodistTheme.white,
      menuMaxHeight: 300,
    );
  }
}

class DistrictMyfDropdowns extends StatefulWidget {
  final String? selectedDistrict;
  final String? selectedMyf;
  final ValueChanged<String?>? onDistrictChanged;
  final ValueChanged<String?>? onMyfChanged;
  final String? Function(String?)? districtValidator;
  final String? Function(String?)? myfValidator;
  final List<String> districts;
  final Map<String, List<String>> districtMyfMap;

  const DistrictMyfDropdowns({
    super.key,
    this.selectedDistrict,
    this.selectedMyf,
    this.onDistrictChanged,
    this.onMyfChanged,
    this.districtValidator,
    this.myfValidator,
    required this.districts,
    required this.districtMyfMap,
  });

  @override
  State<DistrictMyfDropdowns> createState() => _DistrictMyfDropdownsState();
}

class _DistrictMyfDropdownsState extends State<DistrictMyfDropdowns> {
  List<String> get availableMyfs {
    if (widget.selectedDistrict == null) return [];
    return widget.districtMyfMap[widget.selectedDistrict] ?? [];
  }

  void _handleDistrictChange(String? newDistrict) {
    // Clear MYF selection when district changes
    widget.onMyfChanged?.call(null);
    widget.onDistrictChanged?.call(newDistrict);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // District Dropdown
        DependentDropdownField<String>(
          value: widget.selectedDistrict,
          items: widget.districts,
          label: 'District',
          hint: 'Select your district',
          onChanged: _handleDistrictChange,
          validator: widget.districtValidator,
          itemBuilder: (district) => Text(
            district,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: MethodistTheme.bodyMedium,
          ),
        ),

        SizedBox(height: MethodistTheme.spacingM),

        // MYF Dropdown
        DependentDropdownField<String>(
          value: availableMyfs.contains(widget.selectedMyf)
              ? widget.selectedMyf
              : null,
          items: availableMyfs,
          label: 'Church/MYF',
          hint: widget.selectedDistrict == null
              ? 'First select a district'
              : 'Select your church/MYF',
          onChanged: widget.onMyfChanged,
          validator: widget.myfValidator,
          enabled: widget.selectedDistrict != null && availableMyfs.isNotEmpty,
          itemBuilder: (myf) => Text(
            myf,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: MethodistTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}