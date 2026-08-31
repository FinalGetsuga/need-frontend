import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:need_mobile_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/api_exception.dart';
import '../../utils/app_colors.dart';
import '../../utils/auth_exception.dart';
import '../../widgets/auth_error_banner.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = () => _showComingSoon('Terms of Service');
    _privacyRecognizer = TapGestureRecognizer()..onTap = () => _showComingSoon('Privacy Policy');
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label - coming soon')));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().register(
        _emailController.text.trim(),
        _passwordController.text,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );

      if (!mounted) return;

      await context.read<UserProvider>().loadCurrentUser();

      final navigator = Navigator.of(context);
      navigator.pop();
      if (navigator.canPop()) navigator.pop();
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } on ApiException catch (e) {
      setState(() => _errorMessage =
      "Account created, but we couldn't save your profile (${e.message}). Try logging in - you can update your name later.");
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Sign up to get started',
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              AuthErrorBanner(message: _errorMessage!),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _firstNameController,
                    hintText: 'First name',
                    icon: Icons.person_outline,
                    validator: (v) => _validateRequired(v, 'First name'),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AuthTextField(
                    controller: _lastNameController,
                    hintText: 'Last name',
                    icon: Icons.person_outline,
                    validator: (v) => _validateRequired(v, 'Last name'),
                    enabled: !_isLoading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _emailController,
              hintText: 'Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              validator: _validateEmail,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _passwordController,
              hintText: 'Password',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
              validator: _validatePassword,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirm password',
              icon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              validator: _validateConfirmPassword,
              enabled: !_isLoading,
              onFieldSubmitted: (_) {
                if (_agreedToTerms) _onRegisterPressed();
              },
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _agreedToTerms,
                    onChanged: _isLoading ? null : (v) => setState(() => _agreedToTerms = v ?? false),
                    activeColor: AppColors.primary,
                    checkColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade500),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13, height: 1.4),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(color: AppColors.primary, decoration: TextDecoration.underline),
                            recognizer: _termsRecognizer,
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(color: AppColors.primary, decoration: TextDecoration.underline),
                            recognizer: _privacyRecognizer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Create account',
              isLoading: _isLoading,
              onPressed: _agreedToTerms ? _onRegisterPressed : null,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                GestureDetector(
                  onTap: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Login',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}