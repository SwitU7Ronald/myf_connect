import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool enabled;
  const AppTextField({super.key, required this.controller, required this.label, this.keyboardType, this.enabled=true});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}
