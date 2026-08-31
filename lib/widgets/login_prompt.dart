import 'package:flutter/material.dart';
import 'package:need_mobile_app/screens/auth/login_screen.dart';
import 'package:need_mobile_app/widgets/primary_button.dart';

class LoginPrompt extends StatelessWidget{
  final String message;
  const LoginPrompt({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 20),
                PrimaryButton(
                    label: 'Log In',
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()))
                ),
              ],
            ),
        ),
      ),
    );
  }
}