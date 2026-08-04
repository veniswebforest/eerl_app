import 'dart:async';
import 'package:flutter/material.dart';

/// Manages auth state (phone input, OTP input, countdown timer, validation, errors, API loading).
class AuthProvider extends ChangeNotifier {
  String _phoneNumber = '';
  String _otp = '';
  bool _isLoading = false;
  bool _hasLoginError = false;
  bool _hasOtpError = false;
  bool _isVerified = false;
  bool _loginAttempted = false;

  // Resend countdown timer
  int _resendSeconds = 30;
  Timer? _resendTimer;

  // Getters
  String get phoneNumber => _phoneNumber;
  String get otp => _otp;
  bool get isLoading => _isLoading;
  bool get hasLoginError => _hasLoginError;
  bool get hasOtpError => _hasOtpError;
  bool get isVerified => _isVerified;
  bool get loginAttempted => _loginAttempted;
  int get resendSeconds => _resendSeconds;

  bool get isPhoneValid => _phoneNumber.length == 10;
  bool get isOtpComplete => _otp.length == 5;

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    _hasLoginError = false;
    notifyListeners();
  }

  void setOtp(String otp) {
    _otp = otp;
    _hasOtpError = false;
    notifyListeners();
  }

  void setLoginAttempted(bool attempted) {
    _loginAttempted = attempted;
    notifyListeners();
  }

  void startResendTimer() {
    _resendSeconds = 30;
    _resendTimer?.cancel();
    notifyListeners();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
      } else {
        _resendSeconds--;
        notifyListeners();
      }
    });
  }

  void cancelTimer() {
    _resendTimer?.cancel();
  }

  Future<bool> sendOtp() async {
    _loginAttempted = true;
    if (!isPhoneValid) {
      _hasLoginError = true;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    // Simulate API request
    await Future.delayed(const Duration(milliseconds: 800));

    _isLoading = false;
    startResendTimer();
    notifyListeners();
    return true;
  }

  Future<bool> verifyOtp() async {
    if (!isOtpComplete) return false;

    _isLoading = true;
    _hasOtpError = false;
    notifyListeners();

    // Simulate API request
    await Future.delayed(const Duration(milliseconds: 1200));

    _isLoading = false;
    if (_otp == '12345') {
      _isVerified = true;
      notifyListeners();
      return true;
    } else {
      _hasOtpError = true;
      notifyListeners();
      return false;
    }
  }

  void resendOtp() {
    if (_resendSeconds > 0) return;
    _hasOtpError = false;
    startResendTimer();
    notifyListeners();
  }

  void reset() {
    _phoneNumber = '';
    _otp = '';
    _isLoading = false;
    _hasLoginError = false;
    _hasOtpError = false;
    _isVerified = false;
    _loginAttempted = false;
    _resendTimer?.cancel();
    _resendSeconds = 30;
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}
