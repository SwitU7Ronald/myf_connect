import 'package:flutter/material.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


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
      initialValue: value,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child:
              itemBuilder?.call(item) ??
              Text(
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
          borderRadius: context.radiusMd,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.spacingMd,
          vertical: context.spacingMd,
        ),
      ),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      style: context.typography.bodyMedium!,
      dropdownColor: context.colors.surface,
      menuMaxHeight: 300,
    );
  }
}
