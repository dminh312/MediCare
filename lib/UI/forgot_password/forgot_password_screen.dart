import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medicare/logic/viewmodels/forgot_password_viewmodel.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgotPasswordViewModel = Provider.of<ForgotPasswordViewModel>(context, listen: false);
    const primaryColor = Color(0xFFea2a4a);
    const textColor = Color(0xFF181112);
    const secondaryTextColor = Color(0xFF5e4b4d);
    const backgroundColor = Color(0xFFf8f6f6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_reset, color: primaryColor, size: 50),
                      ),
                      const SizedBox(height: 32),
                      const Text('Forgot Password?', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 16),
                      const Text(
                        'Enter the email address associated with your account and we\'ll send you a link to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: secondaryTextColor, height: 1.5),
                      ),
                      const SizedBox(height: 40),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Email Address', style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 16)),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'name@example.com',
                          hintStyle: const TextStyle(color: Color(0xFF886369)),
                          suffixIcon: const Icon(Icons.mail, color: Color(0xFF886369), size: 22),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Color(0xFFe5dcdd), width: 1)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Color(0xFFe5dcdd), width: 1)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryColor.withOpacity(0.4), width: 2)),
                        ),
                        validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await forgotPasswordViewModel
                                  .sendPasswordResetEmail(_emailController.text);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Password reset link sent! Check your email.')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          elevation: 5,
                          shadowColor: primaryColor.withOpacity(0.3),
                        ),
                        child: const Text('Reset Password', style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.chevron_left, color: primaryColor, size: 20),
                    label: const Text('Back to Login', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 14)),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10)),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [Text('I can\'t remember', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 14, height: 1.1)), Text('my email', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 14, height: 1.1))],
                    ),
                    label: const Icon(Icons.help_outline, color: primaryColor, size: 20),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(width: 134, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(100))),
            ),
          ],
        ),
      ),
    );
  }
}
