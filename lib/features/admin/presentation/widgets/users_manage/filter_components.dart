import 'package:flutter/material.dart';
import 'package:myf_connect/core/theme/theme.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


class FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.typography.labelMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: context.spacingXs),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border.all(
              color: context.colors.textSecondary.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(context.radiusS),
          ),
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              isDense: true,
            ),
            isExpanded: true,
            menuMaxHeight: 250,
            style: context.typography.bodyMedium?.copyWith(
              fontSize: context.responsiveFontSize(14),
              color: context.colors.textPrimary,
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: context.colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class PermissionTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const PermissionTypeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.radiusS),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.spacing(10),
          horizontal: context.spacingMd,
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : context.colors.surface,
          borderRadius: BorderRadius.circular(context.radiusS),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? context.colors.surface : context.colors.textSecondary,
            ),
            SizedBox(width: context.spacingSm),
            Flexible(
              child: Text(
                label,
                style: context.typography.bodyMedium?.copyWith(
                  fontSize: context.responsiveFontSize(13),
                  color: isSelected
                      ? context.colors.surface
                      : context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
