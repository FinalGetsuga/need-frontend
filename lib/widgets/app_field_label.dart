import 'package:flutter/material.dart';

class AppFieldLabel extends StatelessWidget{
  final String label;
  final bool required;

  const AppFieldLabel({
    super.key,
    required this.label,
    this.required = false
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
          children: [
            TextSpan(text: label),
            if (required) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
    );
  }
}