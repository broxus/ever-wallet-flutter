import 'dart:async';

import 'package:ever_wallet/data/models/site_meta_data.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:favicon/favicon.dart';
import 'package:simple_link_preview/simple_link_preview.dart';
import 'package:validators/validators.dart';

class SitesMetaDataRepository {
  final HiveSource _hiveSource;

  const SitesMetaDataRepository(this._hiveSource);

  Future<SiteMetaData> getSiteMetaData(String url) async {
    final cached = _hiveSource.getSiteMetaData(url);

    if (cached != null) return cached;

    final isUrl = isURL(url);
    final linkPreview = isUrl ? await SimpleLinkPreview.getPreview(url) : null;
    final favicon = isUrl ? await FaviconFinder.getBest(url) : null;

    final siteMetaData = SiteMetaData(
      url: url,
      title: linkPreview?.title,
      image: favicon?.url ?? linkPreview?.url,
      description: linkPreview?.description,
    );

    await _hiveSource.cacheSiteMetaData(url: url, metaData: siteMetaData);

    return siteMetaData;
  }

  Future<void> clear() => _hiveSource.clearSitesMetaData();
}
