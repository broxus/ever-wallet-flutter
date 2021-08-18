import '../models/connected_site.dart';

abstract class ConnectedSitesRepository {
  Future<List<ConnectedSite>> getConnectedSites(String address);

  Future<void> addConnectedSite({
    required String address,
    required ConnectedSite site,
  });

  Future<void> removeConnectedSite({
    required String address,
    required String url,
  });

  Future<void> clear();
}
