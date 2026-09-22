import 'package:eerl_app/features/auth/data/auth_remote_service.dart';
import 'package:eerl_app/features/auth/data/auth_session_storage.dart';
import 'package:eerl_app/features/auth/model/send_otp_request.dart';
import 'package:eerl_app/features/auth/model/send_otp_response.dart';
import 'package:eerl_app/features/auth/model/verify_otp_request.dart';
import 'package:eerl_app/features/auth/model/verify_otp_response.dart';

class AuthRepository {
  AuthRepository({
    AuthRemoteService? remoteService,
    AuthSessionStorage? sessionStorage,
  }) : _remoteService = remoteService ?? AuthRemoteService(),
       _sessionStorage = sessionStorage ?? AuthSessionStorage(),
       _ownsRemoteService = remoteService == null;

  final AuthRemoteService _remoteService;
  final AuthSessionStorage _sessionStorage;
  final bool _ownsRemoteService;

  Future<SendOtpResponse> sendOtp(String phone) {
    return _remoteService.sendOtp(SendOtpRequest(phone: phone));
  }

  Future<VerifyOtpResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _remoteService.verifyOtp(
      VerifyOtpRequest(phone: phone, otp: otp),
    );
    await _sessionStorage.saveSession(response);
    return response;
  }

  void close() {
    if (_ownsRemoteService) _remoteService.close();
  }
}
