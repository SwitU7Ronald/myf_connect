import 'package:flutter/material.dart';
import 'package:myf_connect/core/themes/theme.dart';

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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: MyfTheme.mediumGray,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: MyfTheme.white,
            border: Border.all(
              color: MyfTheme.mediumGray.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
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
            style: const TextStyle(fontSize: 14, color: MyfTheme.darkGray),
            icon: const Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: MyfTheme.mediumGray,
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? MyfTheme.primaryRed : MyfTheme.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? MyfTheme.primaryRed
                : MyfTheme.mediumGray.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? MyfTheme.white : MyfTheme.mediumGray,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? MyfTheme.white : MyfTheme.darkGray,
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
