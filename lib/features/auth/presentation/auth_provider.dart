import 'dart:async';
import 'package:eerl_app/features/auth/data/auth_repository.dart';
import 'package:eerl_app/features/auth/model/auth_api_exception.dart';
import 'package:eerl_app/features/auth/model/send_otp_response.dart';
import 'package:eerl_app/features/auth/model/verify_otp_response.dart';
import 'package:flutter/material.dart';

/// Manages auth state (phone input, OTP input, countdown timer, validation, errors, API loading).
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository(),
      _ownsRepository = repository == null;

  static const _tag = '[AuthProvider]';

  final AuthRepository _repository;
  final bool _ownsRepository;

  String _phoneNumber = '';
  String _otp = '';
  bool _isLoading = false;
  bool _hasLoginError = false;
  bool _hasOtpError = false;
  bool _isVerified = false;
  bool _loginAttempted = false;
  String? _errorMessage;
  SendOtpResponse? _sendOtpResponse;
  VerifyOtpResponse? _verifyOtpResponse;

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
  String? get errorMessage => _errorMessage;
  SendOtpResponse? get sendOtpResponse => _sendOtpResponse;
  VerifyOtpResponse? get verifyOtpResponse => _verifyOtpResponse;

  bool get isPhoneValid => RegExp(r'^[6-9]\d{9}$').hasMatch(_phoneNumber);
  bool get isOtpComplete => RegExp(r'^\d{6}$').hasMatch(_otp);

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    _hasLoginError = false;
    _errorMessage = null;
    notifyListeners();
  }

  void setOtp(String otp) {
    _otp = otp;
    _hasOtpError = false;
    _errorMessage = null;
    notifyListeners();
  }

  void setLoginAttempted(bool attempted) {
    _loginAttempted = attempted;
    notifyListeners();
  }

  void startResendTimer({int seconds = 30}) {
    _resendSeconds = seconds;
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
    debugPrint('$_tag Send OTP event start');
    _loginAttempted = true;
    if (!isPhoneValid) {
      debugPrint(
        '$_tag Validation failed: invalid 10-digit Indian mobile number',
      );
      _hasLoginError = true;
      _errorMessage = null;
      notifyListeners();
      return false;
    }

    debugPrint('$_tag Loading state start');
    _isLoading = true;
    _hasLoginError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.sendOtp(_phoneNumber);
      _sendOtpResponse = response;
      _otp = '';
      _hasOtpError = false;
      _isVerified = false;
      _verifyOtpResponse = null;
      final expirySeconds = response.expiresInSeconds;
      startResendTimer(
        seconds: expirySeconds != null && expirySeconds > 0
            ? expirySeconds
            : 30,
      );
      debugPrint('$_tag Success state: OTP request completed');
      return true;
    } on AuthApiException catch (error, stackTrace) {
      _errorMessage = error.message;
      _hasLoginError = error.field == 'phone';
      debugPrint(
        '$_tag Error state: code=${error.code}, status=${error.statusCode}',
      );
      debugPrintStack(label: '$_tag Stack Trace', stackTrace: stackTrace);
      return false;
    } catch (error, stackTrace) {
      _errorMessage = 'Unable to send the login code. Please try again.';
      debugPrint('$_tag Catch block error: $error');
      debugPrintStack(label: '$_tag Stack Trace', stackTrace: stackTrace);
      return false;
    } finally {
      _isLoading = false;
      debugPrint('$_tag Loading state stop');
      notifyListeners();
    }
  }

  Future<bool> verifyOtp() async {
    debugPrint('$_tag Verify OTP event start');
    if (!isPhoneValid) {
      _hasOtpError = true;
      _errorMessage = 'Enter a valid 10-digit Indian mobile number.';
      debugPrint('$_tag Validation failed: invalid phone number');
      notifyListeners();
      return false;
    }
    if (!isOtpComplete) {
      _hasOtpError = true;
      _errorMessage = 'Enter the complete 6-digit login code.';
      debugPrint('$_tag Validation failed: OTP must contain 6 digits');
      notifyListeners();
      return false;
    }

    debugPrint('$_tag Verify loading state start');
    _isLoading = true;
    _hasOtpError = false;
    _isVerified = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.verifyOtp(
        phone: _phoneNumber,
        otp: _otp,
      );
      _verifyOtpResponse = response;
      _isVerified = true;
      debugPrint('$_tag Verify success state: authenticated session stored');
      return true;
    } on AuthApiException catch (error, stackTrace) {
      _hasOtpError = true;
      _errorMessage = error.message;
      debugPrint(
        '$_tag Verify error state: code=${error.code}, status=${error.statusCode}',
      );
      debugPrintStack(
        label: '$_tag Verify Stack Trace',
        stackTrace: stackTrace,
      );
      return false;
    } catch (error, stackTrace) {
      _hasOtpError = true;
      _errorMessage = 'Unable to verify the login code. Please try again.';
      debugPrint('$_tag Verify catch block error: $error');
      debugPrintStack(
        label: '$_tag Verify Stack Trace',
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _isLoading = false;
      debugPrint('$_tag Verify loading state stop');
      notifyListeners();
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
    _errorMessage = null;
    _sendOtpResponse = null;
    _verifyOtpResponse = null;
    _resendTimer?.cancel();
    _resendSeconds = 30;
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    if (_ownsRepository) _repository.close();
    super.dispose();
  }
}
