import 'package:injectable/injectable.dart';

import '../../domain/models/connected_site.dart';
import '../../domain/repositories/connected_sites_repository.dart';
import '../dtos/connected_site_dto.dart';
import '../sources/local/hive_source.dart';

@LazySingleton(as: ConnectedSitesRepository)
class ConnectedSitesRepositoryImpl implements ConnectedSitesRepository {
  final HiveSource _hiveSource;

  ConnectedSitesRepositoryImpl(this._hiveSource);

  @override
  Future<List<ConnectedSite>> getConnectedSites(String address) async {
    final connectedSites = await _hiveSource.getConnectedSites(address);

    return connectedSites.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> addConnectedSite({
    required String address,
    required ConnectedSite site,
  }) async {
    final connectedSite = ConnectedSiteDto.fromDomain(site);

    await _hiveSource.addConnectedSite(
      address: address,
      site: connectedSite,
    );
  }

  @override
  Future<void> removeConnectedSite({
    required String address,
    required String url,
  }) async =>
      _hiveSource.removeConnectedSite(
        address: address,
        url: url,
      );

  @override
  Future<void> clear() => _hiveSource.clearConnectedSites();
}
