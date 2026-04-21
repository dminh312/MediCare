import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback? onUnlock;
  const AppLockScreen({super.key, this.onUnlock});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _showPinScreen = false;
  String _enteredPin = '';
  String? _correctPin;
  int _pinLength = 4;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _correctPin = prefs.getString('app_lock_pin');
    if (_correctPin != null) {
      _pinLength = _correctPin!.length;
    }
    _authenticateBiometric();
  }

  Future<void> _authenticateBiometric() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (canCheckBiometrics || isDeviceSupported) {
        final didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to unlock MediCare',
        );

        if (didAuthenticate && mounted) {
          if (widget.onUnlock != null) {
            widget.onUnlock!();
          } else {
            Navigator.of(context).pop(); // Unlock successful
          }
        } else {
          // Failed or canceled
          setState(() {
            _showPinScreen = true;
          });
        }
      } else {
        // No biometric support, fallback to PIN
        setState(() {
          _showPinScreen = true;
        });
      }
    } catch (e) {
      debugPrint('Biometric Auth Error: $e');
      setState(() {
        _showPinScreen = true;
      });
    }
  }

  void _onKeyPress(String value) {
    setState(() {
      _hasError = false;
      if (_enteredPin.length < _pinLength) {
        _enteredPin += value;
      }
      
      if (_enteredPin.length == _pinLength) {
        if (_enteredPin == _correctPin) {
          if (widget.onUnlock != null) {
            widget.onUnlock!();
          } else {
            Navigator.of(context).pop(); // Correct PIN, unlock
          }
        } else {
          setState(() {
            _hasError = true;
            _enteredPin = '';
          });
        }
      }
    });
  }

  void _onDeletePress() {
    setState(() {
      _hasError = false;
      if (_enteredPin.isNotEmpty) {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      }
    });
  }

  Widget _buildPinIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < _enteredPin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? const Color(0xFFFF5252)
                : const Color(0xFFFF5252).withOpacity(0.2),
            border: Border.all(
              color: isFilled ? Colors.transparent : const Color(0xFFFF5252).withOpacity(0.3),
              width: 2,
            ),
          ),
        );
      }),
    ).animate(target: _hasError ? 1 : 0).shakeX();
  }

  Widget _buildNumpad() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = constraints.maxWidth > 400 ? 40 : 20;
        return SizedBox(
          width: (72 * 3) + (spacing * 2),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing,
            runSpacing: 20,
            children: [
              for (int i = 1; i <= 9; i++) _buildPadButton(i.toString()),
              _buildBiometricButton(),
              _buildPadButton('0'),
              _buildPadButton('⌫', isDelete: true),
            ],
          ),
        );
      }
    );
  }

  Widget _buildPadButton(String text, {bool isDelete = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDelete ? _onDeletePress : () => _onKeyPress(text),
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFF5252).withOpacity(0.05),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1111),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _authenticateBiometric,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFF5252).withOpacity(0.05),
          ),
          child: const Icon(
            Icons.fingerprint,
            size: 32,
            color: Color(0xFFFF5252),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFBFB),
        body: SafeArea(
          child: _showPinScreen
              ? SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                    const SizedBox(height: 60),
                    const Icon(Icons.lock_outline, size: 48, color: Color(0xFFFF5252)),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter PIN',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1111),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _hasError ? 'Incorrect PIN, try again' : 'Please enter your PIN to unlock',
                      style: TextStyle(
                        fontSize: 14,
                        color: _hasError ? const Color(0xFFFF5252) : const Color(0xFF534343),
                        fontWeight: _hasError ? FontWeight.w600 : FontWeight.normal,
                        fontFamily: 'Plus Jakarta Sans',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildPinIndicator(),
                    const Spacer(),
                    _buildNumpad(),
                    const SizedBox(height: 48),
                  ],
                ),
              ).animate().fade()
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.fingerprint,
                        size: 80,
                        color: Color(0xFFFF5252),
                      ).animate().shimmer(duration: 2.seconds),
                      const SizedBox(height: 24),
                      const Text(
                        'Unlock MediCare',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1111),
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
