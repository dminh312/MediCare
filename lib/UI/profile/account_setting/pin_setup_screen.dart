import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicare/UI/profile/account_setting/app_lock_success_screen.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _initialPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  int _pinLength = 4; // Default to 4 digits
  bool _hasError = false;

  void _onKeyPress(String value) {
    setState(() {
      _hasError = false;
      if (!_isConfirming) {
        if (_initialPin.length < _pinLength) {
          _initialPin += value;
        }
        if (_initialPin.length == _pinLength) {
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {
              _isConfirming = true;
            });
          });
        }
      } else {
        if (_confirmPin.length < _pinLength) {
          _confirmPin += value;
        }
        if (_confirmPin.length == _pinLength) {
          if (_confirmPin == _initialPin) {
            _savePinAndContinue();
          } else {
            // Error, reset confirmation
            setState(() {
              _hasError = true;
              _confirmPin = '';
            });
          }
        }
      }
    });
  }

  void _onDeletePress() {
    setState(() {
      _hasError = false;
      if (!_isConfirming) {
        if (_initialPin.isNotEmpty) {
          _initialPin = _initialPin.substring(0, _initialPin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      }
    });
  }

  Future<void> _savePinAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lock_pin', _confirmPin);
    await prefs.setBool('is_biometric_lock_enabled', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppLockSuccessScreen()),
      );
    }
  }

  Widget _buildPinIndicator() {
    final currentInput = _isConfirming ? _confirmPin : _initialPin;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < currentInput.length;
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
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: constraints.maxWidth > 400 ? 40 : 20,
          runSpacing: 20,
          children: [
            for (int i = 1; i <= 9; i++) _buildPadButton(i.toString()),
            _buildPadButton('', isTransparent: true),
            _buildPadButton('0'),
            _buildPadButton('⌫', isDelete: true),
          ],
        );
      }
    );
  }

  Widget _buildPadButton(String text, {bool isDelete = false, bool isTransparent = false}) {
    if (isTransparent) {
      return const SizedBox(width: 72, height: 72);
    }
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
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1111),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFB),
      appBar: AppBar(
        title: Text(
          _isConfirming ? 'Confirm PIN' : 'Setup PIN',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFF1A1111),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF1A1111), size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isConfirming)
            TextButton(
              onPressed: () {
                setState(() {
                  _pinLength = _pinLength == 4 ? 6 : 4;
                  _initialPin = '';
                  _confirmPin = '';
                  _hasError = false;
                });
              },
              child: Text(
                _pinLength == 4 ? 'Use 6-digit' : 'Use 4-digit',
                style: const TextStyle(
                  color: Color(0xFFFF5252),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              _isConfirming ? 'Confirm your new PIN' : 'Create a new PIN',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1111),
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isConfirming
                  ? 'Please re-enter your PIN to confirm'
                  : 'This PIN will be used as a fallback if\nbiometrics fail.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _hasError ? const Color(0xFFFF5252) : const Color(0xFF534343),
                fontWeight: _hasError ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'Plus Jakarta Sans',
                height: 1.5,
              ),
            ),
            const Spacer(),
            _buildPinIndicator(),
            const Spacer(),
            _buildNumpad(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
