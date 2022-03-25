import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:simple_link_preview/simple_link_preview.dart';

import '../models/site_meta_data.dart';
import '../sources/local/hive_source.dart';

@lazySingleton
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

  Future<void> removeSiteMetaData(String url) => _hiveSource.removeSiteMetaData(url);

  Future<void> clear() => _hiveSource.clearSitesMetaData();
}
