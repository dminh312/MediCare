
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medicare/logic/viewmodels/login_viewmodel.dart';
import 'package:medicare/UI/signup/signup_screen.dart';
import 'package:medicare/UI/forgot_password/forgot_password_screen.dart';
import 'package:medicare/UI/home/home_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    if (email != null && password != null) {
      _emailController.text = email;
      _passwordController.text = password;
      setState(() {
        _rememberMe = true;
      });
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }

    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    String? errorMessage;
    try {
      errorMessage = await loginViewModel.signIn(_emailController.text, _passwordController.text);
    } catch (e) {
      errorMessage = e.toString();
    }

    if(mounted) {
      setState(() => _isLoading = false);
    }

    if (mounted && errorMessage == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeView()));
    } else if (mounted && errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  void _signInWithGoogle() async {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    String? errorMessage;
    try {
      errorMessage = await loginViewModel.signInWithGoogle();
    } catch (e) {
      errorMessage = e.toString();
    }

    if (mounted && errorMessage == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeView()));
    } else if (mounted && errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // New Design Colors
    const primaryColor = Color(0xFFF43F5E);
    const backgroundLightColor = Color(0xFFF8FAFC);
    const slate900 = Color(0xFF0F172A); // Roughly slate-900
    const slate500 = Color(0xFF64748B); // Roughly slate-500
    const slate200 = Color(0xFFE2E8F0); // Roughly slate-200

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF020617) : backgroundLightColor;
    final textColor = isDarkMode ? Colors.white : slate900;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : slate500;
    final ringColor = isDarkMode ? Colors.grey[700] : slate200;
    final formBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white; // slate-800

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            _buildHeader(primaryColor, textColor),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  const SizedBox(height: 24),
                  _buildWelcomeText(textColor, secondaryTextColor),
                  const SizedBox(height: 32),
                  _buildLoginForm(context, textColor, formBgColor, primaryColor, ringColor, secondaryTextColor),
                  const SizedBox(height: 24),
                  _buildSocialButtons(context, textColor, formBgColor, ringColor),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            _buildSignUpFooter(context, secondaryTextColor, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor, Color textColor) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), spreadRadius: 4, blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: const Icon(Icons.medical_services, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            text: 'MediCare',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textColor, fontFamily: 'Plus Jakarta Sans'),
            children: <TextSpan>[TextSpan(text: '+', style: TextStyle(color: primaryColor, fontSize: 28, fontWeight: FontWeight.w800, fontFamily: 'Plus Jakarta Sans'))],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText(Color textColor, Color? secondaryTextColor) {
    return Column(
      children: [
        Text('Welcome Back', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Plus Jakarta Sans')),
        const SizedBox(height: 8.0),
        Text('Sign in to continue your health journey.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: secondaryTextColor, fontFamily: 'Plus Jakarta Sans')),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, Color textColor, Color formBgColor, Color primaryColor, Color? ringColor, Color? secondaryTextColor) {
    const slate400 = Color(0xFF94A3B8);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email or Username', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Plus Jakarta Sans')),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: textColor, fontFamily: 'Plus Jakarta Sans'),
            decoration: _customInputDecoration(hintText: 'example@medicare.plus', prefixIcon: Icons.mail, primaryColor: primaryColor, ringColor: ringColor, formBgColor: formBgColor, secondaryTextColor: secondaryTextColor),
            validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16.0),
          Text('Password', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Plus Jakarta Sans')),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: textColor, fontFamily: 'Plus Jakarta Sans'),
            decoration: _customInputDecoration(
              hintText: '••••••••',
              prefixIcon: Icons.lock,
              primaryColor: primaryColor,
              ringColor: ringColor,
              formBgColor: formBgColor,
              secondaryTextColor: secondaryTextColor
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: secondaryTextColor, size: 20),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'Please enter your password' : null,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (bool? value) => setState(() => _rememberMe = value ?? false),
                activeColor: primaryColor,
                checkColor: Colors.white,
                side: BorderSide(color: ringColor!, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              Text('Remember me', style: TextStyle(fontWeight: FontWeight.w600, color: secondaryTextColor, fontFamily: 'Plus Jakarta Sans')),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
              elevation: 4,
              shadowColor: primaryColor.withOpacity(0.2),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                : const Text('Log In', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')),
          ),
          const SizedBox(height: 16),
          Center(
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.face_unlock_outlined, size: 36, color: slate400),
              tooltip: 'Use Face ID',
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPasswordView())),
              child: Text('Forgot Password?', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _customInputDecoration({required String hintText, required IconData prefixIcon, required Color primaryColor, Color? ringColor, Color? formBgColor, Color? secondaryTextColor}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: secondaryTextColor, fontFamily: 'Plus Jakarta Sans'),
      prefixIcon: Icon(prefixIcon, color: secondaryTextColor, size: 20),
      filled: true,
      fillColor: formBgColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: ringColor ?? Colors.transparent, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryColor, width: 2)),
    );
  }

  Widget _buildSocialButtons(BuildContext context, Color textColor, Color formBgColor, Color? ringColor) {
    const slate500 = Color(0xFF64748B);
    return Column(
      children: [
        const Row(children: <Widget>[Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Or continue with', style: TextStyle(color: slate500, fontFamily: 'Plus Jakarta Sans'))), Expanded(child: Divider())]),
        const SizedBox(height: 24.0),
        Row(children: <Widget>[
          Expanded(child: _socialButton(context, 'assets/google_logo.png', 'Google', textColor, formBgColor, ringColor, onPressed: _signInWithGoogle)),
          const SizedBox(width: 16),
          Expanded(child: _socialButton(context, null, 'Apple', textColor, formBgColor, ringColor, iconData: Icons.apple, onPressed: () {})),
        ]),
      ],
    );
  }

  Widget _socialButton(BuildContext context, String? assetPath, String label, Color textColor, Color formBgColor, Color? ringColor, {IconData? iconData, required VoidCallback onPressed}){
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: assetPath != null ? Image.asset(assetPath, height: 20) : Icon(iconData, color: textColor, size: 24),
      label: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Plus Jakarta Sans')),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        backgroundColor: formBgColor,
        side: BorderSide(color: ringColor ?? Colors.transparent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }

  Widget _buildSignUpFooter(BuildContext context, Color? secondaryTextColor, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Don't have an account? ", style: TextStyle(color: secondaryTextColor, fontFamily: 'Plus Jakarta Sans')),
          TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpView())),
            child: Text('Sign Up for MediCare+', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')),
          ),
        ],
      ),
    );
  }
}
