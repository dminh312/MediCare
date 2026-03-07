import 'package:flutter/material.dart';
import 'package:medicare/UI/share/tos.dart';
import 'package:provider/provider.dart';
import 'package:medicare/logic/viewmodels/signup_viewmodel.dart';
import 'package:medicare/UI/home/home_view.dart';
import 'package:medicare/main.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final agreed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsOfServiceScreen(isReadOnly: false),
      ),
    );

    if (agreed == true) {
      _performSignUp();
    }
  }

  void _performSignUp() async {
    setState(() => _isLoading = true);

    final signUpViewModel = Provider.of<SignUpViewModel>(context, listen: false);
    String? errorMessage;
    try {
      errorMessage = await signUpViewModel.signUp(_emailController.text, _passwordController.text, _nameController.text);
    } catch (e) {
      errorMessage = e.toString();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (mounted && errorMessage == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    } else if (mounted && errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFea2a33);
    const textColor = Color(0xFF202124);
    const secondaryTextColor = Color(0xFF5F6368);
    const backgroundColor = Color(0xFFF8F6F6);

    InputDecoration customInputDecoration({required String hintText, required IconData suffixIcon}) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: Icon(suffixIcon, color: secondaryTextColor, size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: Colors.grey.shade200, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: textColor, size: 22), onPressed: () => Navigator.of(context).pop()),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.health_and_safety, color: primaryColor, size: 30),
                      ),
                      const SizedBox(height: 16),
                      const Text('Create Account', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 8.0),
                      const Text('Start your journey to better health today.', style: TextStyle(fontSize: 16, color: secondaryTextColor)),
                      const SizedBox(height: 24),
                      const Text('Full Name', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: customInputDecoration(hintText: 'Enter your full name', suffixIcon: Icons.person),
                        validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Email Address', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: customInputDecoration(hintText: 'Enter your email', suffixIcon: Icons.mail),
                        validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Password', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: customInputDecoration(hintText: 'Create a password', suffixIcon: Icons.lock),
                        validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Confirm Password', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: customInputDecoration(hintText: 'Re-enter password', suffixIcon: Icons.lock_reset),
                        validator: (value) => (value != _passwordController.text) ? 'Passwords do not match' : null,
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _onSignUpPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          disabledBackgroundColor: primaryColor.withOpacity(0.5),
                          minimumSize: const Size(double.infinity, 58),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          elevation: 5,
                          shadowColor: primaryColor.withOpacity(0.4),
                        ),
                        child: _isLoading ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 24.0),
                      const Row(
                        children: <Widget>[
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('Or sign up with', style: TextStyle(color: secondaryTextColor, fontSize: 14)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: Image.asset('assets/google_logo.png', height: 22),
                              label: const Text('Google', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.apple, color: Colors.black, size: 26),
                              label: const Text('Apple', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            width: double.infinity,
            color: backgroundColor.withAlpha(200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? ", style: TextStyle(color: secondaryTextColor, fontSize: 14)),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Text('Log In', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
