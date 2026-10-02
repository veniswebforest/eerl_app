import 'package:eerl_app/features/bootstrap/data/bootstrap_remote_service.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';

abstract interface class BootstrapGateway {
  Future<BootstrapResponse> fetch({required String accessToken, String? since});
}

class BootstrapRepository implements BootstrapGateway {
  BootstrapRepository({BootstrapRemoteService? remoteService})
    : _remoteService = remoteService ?? BootstrapRemoteService();

  final BootstrapRemoteService _remoteService;

  @override
  Future<BootstrapResponse> fetch({
    required String accessToken,
    String? since,
  }) {
    return _remoteService.fetchBootstrap(
      accessToken: accessToken,
      since: since,
    );
  }
}
