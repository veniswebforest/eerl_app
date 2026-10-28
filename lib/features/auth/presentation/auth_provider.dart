import 'dart:async';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/features/auth/data/auth_repository.dart';
import 'package:eerl_app/features/auth/model/auth_api_exception.dart';
import 'package:eerl_app/features/auth/model/send_otp_response.dart';
import 'package:eerl_app/features/auth/model/verify_otp_response.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:flutter/material.dart';

/// Manages auth state (phone input, OTP input, countdown timer, validation, errors, API loading).
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository(),
      _ownsRepository = repository == null;

  final AuthRepository _repository;
  final bool _ownsRepository;

  String _phoneNumber = '';
  String _otp = '';
  bool _isLoading = false;
  bool _isResending = false;
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
  bool get isResending => _isResending;
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
    if (_phoneNumber == phone && !_hasLoginError && _errorMessage == null) {
      return;
    }
    _phoneNumber = phone;
    _hasLoginError = false;
    _errorMessage = null;
    notifyListeners();
  }

  void setOtp(String otp) {
    if (_otp == otp && !_hasOtpError && _errorMessage == null) return;
    _otp = otp;
    _hasOtpError = false;
    _errorMessage = null;
    notifyListeners();
  }

  void setLoginAttempted(bool attempted) {
    if (_loginAttempted == attempted) return;
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
    _resendTimer = null;
  }

  Future<bool> sendOtp() async {
    if (_isLoading) return false;
    _loginAttempted = true;
    if (!isPhoneValid) {
      _hasLoginError = true;
      _errorMessage = null;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _isResending = false;
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
      return true;
    } on AuthApiException catch (error) {
      _errorMessage = error.message;
      _hasLoginError = error.field == 'phone';
      return false;
    } catch (error) {
      _errorMessage = 'Unable to send the login code. Please try again.';
      AppLogger.error('AUTH', 'Send OTP failed: $error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp() async {
    if (_isLoading) return false;
    if (!isPhoneValid) {
      _hasOtpError = true;
      _errorMessage = 'Enter a valid 10-digit Indian mobile number.';
      notifyListeners();
      return false;
    }
    if (!isOtpComplete) {
      _hasOtpError = true;
      _errorMessage = 'Enter the complete 6-digit login code.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _isResending = false;
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
      return true;
    } on AuthApiException catch (error) {
      _hasOtpError = true;
      _errorMessage = error.message;
      return false;
    } catch (error) {
      _hasOtpError = true;
      _errorMessage = 'Unable to verify the login code. Please try again.';
      AppLogger.error('AUTH', 'Verify OTP failed: $error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resendOtp() async {
    if (_resendSeconds > 0 || _isLoading) return false;
    if (!isPhoneValid) {
      _errorMessage = 'Enter a valid 10-digit Indian mobile number.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _isResending = true;
    _hasOtpError = false;
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
      return true;
    } on AuthApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error) {
      _errorMessage = 'Unable to resend the login code. Please try again.';
      AppLogger.error('AUTH', 'Resend OTP failed: $error');
      return false;
    } finally {
      _isLoading = false;
      _isResending = false;
      notifyListeners();
    }
  }

  /// Checks if stored session has non-null/non-empty access token and unexpired sessionExpiresAt.
  /// If invalid or expired (out of current time), clears session storage and returns false.
  Future<bool> checkSessionValidity() async {
    final isValid = await _repository.isSessionValid();
    if (!isValid) {
      AppLogger.diagnostic('AUTH_SESSION', 'Invalid session cleared');
      await _repository.clearSession();
    }
    return isValid;
  }

  Future<void> logout() async {
    await BootstrapSyncService.instance.clearForLogout();
    await _repository.clearSession();
    reset();
  }

  void reset() {
    final hadState =
        _phoneNumber.isNotEmpty ||
        _otp.isNotEmpty ||
        _isLoading ||
        _hasLoginError ||
        _hasOtpError ||
        _isVerified ||
        _loginAttempted ||
        _errorMessage != null ||
        _sendOtpResponse != null ||
        _verifyOtpResponse != null ||
        _resendSeconds != 30;
    _phoneNumber = '';
    _otp = '';
    _isLoading = false;
    _isResending = false;
    _hasLoginError = false;
    _hasOtpError = false;
    _isVerified = false;
    _loginAttempted = false;
    _errorMessage = null;
    _sendOtpResponse = null;
    _verifyOtpResponse = null;
    _resendTimer?.cancel();
    _resendSeconds = 30;
    if (hadState) notifyListeners();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    if (_ownsRepository) _repository.close();
    super.dispose();
  }
}
