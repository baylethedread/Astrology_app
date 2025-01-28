// lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;

  const CustomTextField({super.key, 
    required this.controller,
    required this.label,
    required this.isPassword,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: "Enter $label",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your $label";
        }
        return null;
      },
    );
  }
}
