import 'dart:async';

import 'package:ever_wallet/data/models/site_meta_data.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:simple_link_preview/simple_link_preview.dart';

class SitesMetaDataRepository {
  final HiveSource _hiveSource;

  const SitesMetaDataRepository(this._hiveSource);

  Stream<SiteMetaData> getSiteMetaData(String url) async* {
    final cached = _hiveSource.getSiteMetaData(url);

    if (cached != null) yield cached;

    final linkPreview = (await SimpleLinkPreview.getPreview(url))!;

    final siteMetaData = SiteMetaData(
      url: linkPreview.url,
      title: linkPreview.title,
      image: linkPreview.image,
      description: linkPreview.description,
    );

    await _hiveSource.cacheSiteMetaData(url: url, metaData: siteMetaData);

    yield siteMetaData;
  }

  Future<void> clear() => _hiveSource.clearSitesMetaData();
}
