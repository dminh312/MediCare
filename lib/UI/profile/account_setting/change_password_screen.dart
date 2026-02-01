import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicare/UI/login/login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception("No user is currently signed in.");
      }

      // Re-authenticate the user
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(cred);

      // If re-authentication is successful, update the password
      await user.updatePassword(_newPasswordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully. Please log in again.')),
        );
        // Logout and navigate to login screen
        await FirebaseAuth.instance.signOut();
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'An error occurred.')),
          );
       }
    } catch (e) {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: $e')),
          );
       }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final backgroundColor = isDarkMode ? const Color(0xff1a1111) : const Color(0xfffdf8f8);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final Color borderColor = isDarkMode ? Colors.red.shade900.withAlpha(26) : Colors.red.shade50;
    final textColor = isDarkMode ? Colors.grey[300] : Colors.grey[700];
    final subtleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[500];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: (isDarkMode ? surfaceColor : Colors.white).withAlpha(204),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 28, color: isDarkMode ? Colors.grey[200] : Colors.grey[700]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: borderColor, width: 1.0)),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                children: [
                  _buildPasswordField(
                    label: 'Current Password',
                    hint: 'Enter current password',
                    controller: _currentPasswordController,
                    obscureText: !_currentPasswordVisible,
                    onToggleVisibility: () => setState(() => _currentPasswordVisible = !_currentPasswordVisible),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildPasswordField(
                    label: 'New Password',
                    hint: 'Enter new password',
                    controller: _newPasswordController,
                    obscureText: !_newPasswordVisible,
                    onToggleVisibility: () => setState(() => _newPasswordVisible = !_newPasswordVisible),
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Password must be at least 8 characters long.';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Password must contain a number.';
                      }
                      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                        return 'Password must contain a symbol.';
                      }
                      return null;
                    },
                    helperText: 'Must be at least 8 characters with a symbol and a number.',
                  ),
                  const SizedBox(height: 24),
                  _buildPasswordField(
                    label: 'Confirm New Password',
                    hint: 'Re-enter new password',
                    controller: _confirmPasswordController,
                    obscureText: !_confirmPasswordVisible,
                    onToggleVisibility: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                children: [
                  ElevatedButton(
                     onPressed: _isLoading ? null : _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      elevation: 4,
                      shadowColor: primaryColor.withAlpha(64),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                        : const Text('Update Password'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Once updated, you will be logged out of other devices and will need to log in again with your new credentials.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: subtleTextColor, height: 1.5),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final Color borderColor = isDarkMode ? Colors.red.shade900.withAlpha(26) : Colors.red.shade50;
    final labelColor = isDarkMode ? Colors.grey[300] : Colors.grey[700];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: labelColor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: surfaceColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryColor, width: 2.0)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade700, width: 1.5)),
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[400]),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(helperText, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ),
      ],
    );
  }
}
