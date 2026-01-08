
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medicare/logic/viewmodels/login_viewmodel.dart';
import 'package:medicare/UI/signup/signup_view.dart';
import 'package:medicare/UI/forgot_password/forgot_password_view.dart'; // Import the forgot password view

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);
    const primaryColor = Color(0xFFF5385D);
    const textColor = Color(0xFF202124);
    const secondaryTextColor = Color(0xFF5F6368);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Top Section
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: 'MediCare',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'sans-serif', // Use a common clean font
                            color: textColor,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '+',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                           fontFamily: 'sans-serif',
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Sign in to continue your health journey.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: secondaryTextColor,
                           fontFamily: 'sans-serif',
                        ),
                      ),
                    ],
                  ),
                  // Form Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      const Text(
                        'Email or Username',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'example@medicare.plus',
                          prefixIcon: const Icon(Icons.mail_outline, color: secondaryTextColor, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Password',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline, color: secondaryTextColor, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: secondaryTextColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                           border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                           contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPasswordView()));
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Bottom Section
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(double.infinity, 60), // Set height to 60
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0), // Large radius
                          ),
                          elevation: 4,
                          shadowColor: primaryColor.withOpacity(0.4),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      const Icon(Icons.sentiment_satisfied_alt_outlined, color: secondaryTextColor, size: 30),
                      const SizedBox(height: 16.0),
                      const Row(
                        children: <Widget>[
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('Or continue with', style: TextStyle(color: secondaryTextColor)),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: secondaryTextColor),),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpView()));
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: 'Sign Up for ',
                                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'MediCare+',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                       const SizedBox(height: 10.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
